require 'net/ldap'

class User < ActiveRecord::Base
  validates_presence_of :name, :login, :email
    
  # This method is resonsible for populating the User table with the
  # login, name, and email of anybody who might be using the system.
  # The included sample code is to pull in data from Texas State's
  # LDAP system. You'll need to customize this for your institution.
  def self.import_all
    ldap_servers = ['ads1.matrix.txstate.edu','ads2.matrix.txstate.edu']
    base_dn = 'ou=TxState Users,dc=matrix,dc=txstate,dc=edu'
    filter = '(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=matrix,DC=txstate,DC=edu)(|(memberOf=CN=students,OU=Txstate Conscribed Lists,DC=matrix,DC=txstate,DC=edu)(memberOf=CN=staff,OU=Txstate Conscribed Lists,DC=matrix,DC=txstate,DC=edu)(memberOf=CN=faculty,OU=Txstate Conscribed Lists,DC=matrix,DC=txstate,DC=edu)))'

    bind_dn = 'cn=itsldap,ou=TxState Service Accounts,dc=matrix,dc=txstate,dc=edu'
    bind_pass = 'SECRET'
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
      ldap.search(:base => base_dn, :filter => filter ) do |entry|
        name = entry.givenName.to_s.strip + " " + entry.sn.to_s.strip
        login = entry.name.to_s.strip
        email = login + "@txstate.edu"
        user = User.find_or_initialize_by_login :name => name, :login => login, :email => email
        if user.name != name
          user.name = name
          user.save
          logger.info( "Updated: " + email )
          records_updated = records_updated + 1
        elsif user.new_record?
          user.save
          new_records = new_records + 1
        else
          # update timestamp so that we can delete old records later
          user.touch
        end
        records = records + 1
      end
      
      # delete records that haven't been updated for 7 days
      records_deleted = User.destroy_all( ["updated_at < ?", Date.today - 7 ] ).size
      
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
