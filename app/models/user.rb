require 'net/ldap'

class User < ActiveRecord::Base
  has_many :permissions
  has_many :departments, :through => :permissions
  
  validates_presence_of :last_name, :login, :email
  
  def name
    [first_name, last_name].join(" ").strip
  end
  
  def name_and_login
     return nil unless name && login
     name + " (" + login + ")"
  end
    
  def email_header
    "\"#{name}\" <#{email}>"
  end
  
  def self.find_by_name_and_login( name )
    return nil if name.blank?
    elements = name.split(/[(|)]/)
    if elements.size > 1
      User.find_by_login( elements.last )
    else
      User.find_by_login( elements[0] )
    end
  end
  
  def self.find_or_lookup_by_login(login)
    return nil unless login.present?
    return nil if login == 'its-cms-autotest' #pretend its-cms-autotest doesn't exist for testing purposes
    
    user = User.find(:first, :conditions => ['login = ?', login ] )
    if user.blank?
      # try to find in ldap
      import_users(login)
      user = User.find(:first, :conditions => ['login = ?', login ] )
    end
    
    user
  end
  
  def authorized?(item=nil)
    
    # Admins can do anything
    return true if self.admin?
    
    # Non-admins can only edit things in their own departments
    return false if !self.editor? && !instructor?
    
    # Return true if we are just being asked about general editing permissions
    return true if item.nil?

    # Only admins can edit departments
    return false if item.is_a? Department
    
    # Non-admins can create and edit topics in their department
    # Instructors cannot edit topics
    if item.is_a? Topic 
      return self.editor? if item.new_record?
      return self.departments.include?(item.department)
    end
    
    # Non-admins can edit sessions for topics in their department
    # Instructors can edit sessions they are the instructor of.
    if item.is_a? Session 
      return self.departments.include?(item.topic.department) || item.instructor?( self )
    end
    
    # Non-admins can edit reservations for topics in their department
    # Instructors can edit reservations for sessions they are the instructor of.
    if item.is_a? Reservation 
      return self.departments.include?(item.session.topic.department) || item.session.instructor?( self )
    end
    
    # default deny
    return false
  end
  
  # return true if the user has permissions on one or more departments
  def editor?
    @_is_editor ||= self.departments.present?
  end
  
  # return true if the user is an instructor for any session (even in the past)
  def instructor?
    @_is_instructor ||= Session.count( :conditions => [ "sessions.id in (select session_id from sessions_users where user_id = ?) AND cancelled = false", self.id ] ) > 0
  end
  
  def self.import_all
    import_users(nil)
  end

  # This method is resonsible for populating the User table with the
  # login, name, and email of anybody who might be using the system.
  # The included sample code is to pull in data from Texas State's
  # LDAP system. You'll need to customize this for your institution.
  def self.import_users(logins)
    ldap_servers = ['ads1.matrix.txstate.edu','ads2.matrix.txstate.edu']
    base_dn = 'ou=TxState Users,dc=matrix,dc=txstate,dc=edu'
    
    filter = '(&'
    filter <<   '(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=matrix,DC=txstate,DC=edu)'
    if logins.present?
      if logins.is_a? Array
        filter << '(|' << logins.map{|login| "(sAMAccountName=#{login})" }.join('') << ')'
      else
        filter << "(sAMAccountName=#{logins})"
      end
    else
      filter <<   '(|(memberOf=CN=students,OU=Txstate Conscribed Lists,DC=matrix,DC=txstate,DC=edu)'
      filter <<     '(memberOf=CN=staff,OU=Txstate Conscribed Lists,DC=matrix,DC=txstate,DC=edu)'
      filter <<     '(memberOf=CN=faculty,OU=Txstate Conscribed Lists,DC=matrix,DC=txstate,DC=edu)'
      filter <<   ')'
    end
    filter << ')'
    logger.debug("LDAP filter = #{filter}")
    
    bind_dn = 'cn=itsldap,ou=TxState Service Accounts,dc=matrix,dc=txstate,dc=edu'
    bind_pass = begin LDAP_PASSWORD rescue "" end
    
    logger.info("Starting import from LDAP: " + Time.now.to_s )

    server_index = 0
    begin
      ldap = Net::LDAP.new
      ldap.host = ldap_servers[server_index]
      ldap.auth bind_dn, bind_pass
      ldap.bind
    rescue 
      server_index += 1
      if server_index < ldap_servers.size
        retry
      else
        raise
      end
    end

    begin
      # Build the list
      records = records_updated = new_records = 0
      ldap.search(:base => base_dn, :filter => filter, :return_result => false ) do |entry|
        first_name = entry.respond_to?( :givenName ) ? entry.givenName.to_s.strip : ''
        last_name = entry.respond_to?( :sn ) ? entry.sn.to_s.strip : ''
        if last_name.blank? && first_name.blank?
          last_name = 'Unknown'
        elsif last_name.blank?
          last_name = first_name
          first_name = ''
        end
        
        login = entry.name.to_s.strip
        email = login + "@txstate.edu"
        department = nil
        department = entry.department.to_s if entry.respond_to?( :department )
        user = User.find_or_initialize_by_login :first_name => first_name, :last_name => last_name, :login => login, :email => email, :department => department
        if user.first_name != first_name || user.last_name != last_name || user.department != department
          user.first_name = first_name
          user.last_name = last_name
          user.department = department
          user.save
          logger.info( "Updated: " + email )
          records_updated = records_updated + 1
        elsif user.new_record?
          user.save
          new_records = new_records + 1
        else
          # update timestamp so that we can delete old records later
          user.active = true
          user.save
        end
        records = records + 1
      end
      
      # mark inactive records that haven't been updated for 7 days
      records_deleted = User.update_all( 'active = false', ["updated_at < ?", Date.today - 7 ] ).size
      
      logger.info( "LDAP Import Complete: " + Time.now.to_s )
      logger.info( "Total Records Processed: " + records.to_s )
      logger.info( "New Records: " + new_records.to_s )
      logger.info( "Updated Records: " + records_updated.to_s ) 
      logger.info( "Deleted Records: " + records_deleted.to_s )
    rescue
      logger.error("There was a problem importing the data from LDAP.")
      raise
    end
    
  end
end
