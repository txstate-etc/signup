require 'net-ldap'

class Ldap
  # BASE_DN = "DC=matrix,DC=txstate,DC=edu"
  # BIND_DN = "CN=sa-ldap-its,OU=Service Accounts,OU=TxState Objects,#{BASE_DN}"
  # BIND_PASS = Rails.application.secrets.ldap_password
  # USER_BASE = "ou=TxState Users,#{BASE_DN}"
  # LDAP_SERVERS = ['ldap.txstate.edu']
  # QUERY_BASE = '(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=matrix,DC=txstate,DC=edu)'
  # MAIL_DOMAIN = 'txstate.edu'

  class ConnectError < IOError
  end

  def self.import_user(login)
    return nil unless defined? LDAP_SERVERS
    Ldap.new.import_user(login)
  end

  def self.search(query)
    return [] unless defined? LDAP_SERVERS
    Ldap.new.search(query)
  end

  def initialize
    @logger = Rails.logger
    @ldap = Net::LDAP.new
    connect
  end

  def search(query)
    start = Time.now
    query = build_search_query(query)
    results = []
    @ldap.search(:base => USER_BASE, :filter => query, :size => 10, :return_result => false ) do |entry|
      if fields = parse_person_entry(entry)
        results << fields
      end
    end
    finish = Time.now
    @logger.info( "LDAP Search Complete: #{((finish - start) * 1000).to_i}ms" )
    results
  end

  def import_user(login)
    return nil unless login.present?
    
    start = Time.now
    @logger.info("Starting user import from LDAP: #{start}" )

    query = build_user_import_query(login)

    user = nil
    @ldap.search(:base => USER_BASE, :filter => query, :return_result => false ) do |entry|
      if fields = parse_person_entry(entry)
        user = persist_user(fields)
      end
    end
    
    finish = Time.now
    @logger.info( "LDAP user Import Complete: #{finish} (#{((finish - start) * 1000).to_i}ms)" )
    
    user

  rescue => e
    @logger.error("There was a problem importing the user data from LDAP.")
    # ExceptionNotifier.notify_exception(e) if Rails.env == "production"
    raise
  end

  private

  # connect and login to ldap server
  def connect
    @logger.debug("Connecting to LDAP server: #{Time.now}" )

    connected = false
    error = nil
    LDAP_SERVERS.each do |ldap_server| 
      begin
        @ldap.host = ldap_server
        @ldap.port = 636
        @ldap.encryption :simple_tls
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
    query << QUERY_BASE
    
    terms.gsub(/[()]/, '').split.each do |term|
      query << '(|'
      query << "(sAMAccountName=#{term}*)"
      query << "(givenName=#{term}*)"
      query << "(sn=#{term}*)"
      query << "(mail=#{term}*)"
      query << "(proxyaddresses=smtp:#{term}*)"
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
    # possible inputs:
    #  cj32
    #  cj32@txstate.edu
    #  charlesjones@txstate.edu
    #  cj32@otherdomain.com (coincidentally matches a netid, but isn't one)
    address = Mail::Address.new(login) rescue nil
    if address && address.domain == MAIL_DOMAIN && address.local.present?
      query = "(|(sAMAccountName=#{address.local})(mail=#{login})(proxyaddresses=smtp:#{login}))"
    else      
      query = "(sAMAccountName=#{login})"
    end
    
    query = "(&#{QUERY_BASE}#{query})"
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
    
    firstname = entry.givenName.first.to_s.strip.force_encoding('UTF-8')
    lastname = entry.sn.first.to_s.strip.force_encoding('UTF-8')
    full_name = "#{firstname} #{lastname}".strip
    name_prefix = entry.personalTitle.first.to_s.force_encoding('UTF-8') if entry.respond_to?( :personalTitle )
    login = entry.name.first.to_s.strip
    email = "#{login}@#{MAIL_DOMAIN}"
    title = entry.title.first.to_s.strip.force_encoding('UTF-8') if entry.respond_to?( :title )
    department = entry.department.first.to_s.force_encoding('UTF-8') if entry.respond_to?( :department )

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
