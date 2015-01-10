require 'net-ldap'

class Ldap
  TXST_BASE = "DC=matrix,DC=txstate,DC=edu"
  BIND_DN = "cn=itsldap,ou=TxState Service Accounts,#{TXST_BASE}"
  BIND_PASS = Rails.application.secrets.ldap_password
  USER_BASE = "ou=TxState Users,#{TXST_BASE}"

  class ConnectError < IOError
  end

  def self.import_user(login)
    Ldap.new.import_user(login)
  end

  def self.search(query)
    Ldap.new.search(query)
  end

  def initialize
    @logger = Rails.logger
    @ldap = Net::LDAP.new
    connect
  end

  def search(query)
    query = build_search_query(query)
    results = []
    @ldap.search(:base => USER_BASE, :filter => query, :size => 10, :return_result => false ) do |entry|
      if fields = parse_person_entry(entry)
        results << fields
      end
    end
    results
  end

  def import_user(login)
    return nil unless login.present?
    @logger.info("Starting user import from LDAP: #{Time.now}" )

    query = build_user_import_query(login)

    user = nil
    @ldap.search(:base => USER_BASE, :filter => query, :return_result => false ) do |entry|
      if fields = parse_person_entry(entry)
        user = persist_user(fields)
      end
    end
    
    @logger.info( "LDAP user Import Complete: #{Time.now}" )
    
    user

  rescue => e
    @logger.error("There was a problem importing the user data from LDAP.")
    ExceptionNotifier::Notifier.background_exception_notification(e).deliver if Rails.env == "production"
    raise
  end

  private

  # connect and login to ldap server
  def connect
    @logger.debug("Connecting to LDAP server: #{Time.now}" )

    connected = false
    error = nil
    ['ads1.matrix.txstate.edu','ads2.matrix.txstate.edu'].each do |ldap_server| 
      begin
        @ldap.host = ldap_server
        @ldap.auth BIND_DN, BIND_PASS
        connected = @ldap.bind
        @logger.debug("bind result: #{@ldap.get_operation_result}")
        break if connected
        raise "Failed to connect to LDAP server #{ldap_server}. Error: #{@ldap.get_operation_result.message} (#{@ldap.get_operation_result.code})"
      rescue => e
        connected = false
        error = "Failed to connect to LDAP server #{ldap_server}. Error: #{e.message}\n#{e.backtrace}"
      end
      @logger.warn(error)
    end

    # raise exception if not connected
    raise ConnectError, error unless connected

    @logger.debug("connected to #{@ldap.host}.")
  end

  # SELECT name_prefix, first_name, last_name, login FROM `users`  
  # WHERE ((first_name LIKE 'a%' OR last_name LIKE 'a%' OR login LIKE 'a%')
  # AND (first_name LIKE 'b%' OR last_name LIKE 'b%' OR login LIKE 'b%'))
  def build_search_query(terms)
    # givenName, sn, or sAMAccountName start with each term
    query = '(&'
    query << '(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=matrix,DC=txstate,DC=edu)'
    
    terms.gsub(/[()]/, '').split.each do |term|
      query << '(|'
      query << "(sAMAccountName=#{term}*)"
      query << "(givenName=#{term}*)"
      query << "(sn=#{term}*)"
      query << ')'
    end

    query << ')'
    @logger.debug("LDAP query = #{query}")

    query
  end

  #########################################
  #
  # user import stuff
  #
  #########################################

  def build_user_import_query(login)
    query = '(&'
    query <<   '(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=matrix,DC=txstate,DC=edu)'
    query <<    "(sAMAccountName=#{login})"
    query << ')'
    @logger.debug("LDAP query = #{query}")

    query
  end

  # get firstname, lastname, netid, title, and department from one ldap result
  def parse_person_entry(entry)
    # skip entries without all of the fields we care about (firstname, lastname, netid)
    if !(entry.respond_to?( :givenName ) && entry.respond_to?( :sn ) && entry.respond_to?( :name ))
      @logger.debug("Missing fields from following entry:")
      entry.each do |attribute, values|
        @logger.debug "   #{attribute}:"
        values.each do |value|
          @logger.debug "      --->#{value}"
        end
      end
      return nil
    end
    
    firstname = entry.givenName.first.to_s.strip
    lastname = entry.sn.first.to_s.strip
    full_name = "#{firstname} #{lastname}".strip
    name_prefix = entry.personalTitle.first.to_s if entry.respond_to?( :personalTitle )
    login = entry.name.first.to_s.strip
    email = "#{login}@txstate.edu"
    title = entry.title.first.to_s.strip if entry.respond_to?( :title )
    department = entry.department.first.to_s if entry.respond_to?( :department )

    # Strip name_prefix from first_name if it's there
    firstname.gsub!(/^\s*#{name_prefix}\s*/, '')

    {
      :firstname => firstname, 
      :lastname => lastname, 
      :full_name => full_name, 
      :name_prefix => name_prefix, 
      :login => login, 
      :email => email, 
      :title => title, 
      :department => department
    }
  end


  def persist_user(fields)
    # find existing or create new user object
    user = User.find_or_initialize_by(login: fields[:login])

    # populate firstname, lastname, email, department, title in user
    user.email = fields[:email]
    user.first_name = fields[:firstname]
    user.last_name = fields[:lastname]
    user.name_prefix = fields[:name_prefix]
    user.department = fields[:department]
    user.title = fields[:title]

    # save user
    if user.new_record?
      user.save!
      @logger.info( "New: #{fields[:full_name]} (#{fields[:login]})" )
    elsif user.changed?
      user.save!
      @logger.info( "Updated: #{fields[:full_name]} (#{fields[:login]})" )
    else
      # just touch the updated_at field
      user.touch
    end

    user
  end

end
