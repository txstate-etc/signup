class PopulateFirstNameAndLastNameFromLdap < ActiveRecord::Migration
  def self.up
    # This method is resonsible for populating the User table with the
    # first name and last name of anybody who might be using the system.
    # The included sample code is to pull in data from Texas State's
    # LDAP system. You'll need to customize this for your institution.
    ldap_servers = ['ads1.matrix.txstate.edu','ads2.matrix.txstate.edu']
    base_dn = 'ou=TxState Users,dc=matrix,dc=txstate,dc=edu'
    filter = '(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=matrix,DC=txstate,DC=edu)(|(memberOf=CN=students,OU=Txstate Conscribed Lists,DC=matrix,DC=txstate,DC=edu)(memberOf=CN=staff,OU=Txstate Conscribed Lists,DC=matrix,DC=txstate,DC=edu)(memberOf=CN=faculty,OU=Txstate Conscribed Lists,DC=matrix,DC=txstate,DC=edu)))'

    bind_dn = 'cn=itsldap,ou=TxState Service Accounts,dc=matrix,dc=txstate,dc=edu'
    bind_pass = 'SECRET'
    puts("Starting import from LDAP: " + Time.now.to_s )
    
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
      records = records_updated = 0
      ldap.search(:base => base_dn, :filter => filter, :return_result => false ) do |entry|
        login = entry.name.to_s.strip        
        user = User.find_by_login login
        records = records + 1
        next unless user        
        user.first_name = entry.givenName.to_s.strip
        user.last_name = entry.sn.to_s.strip
        user.save
        puts( "Updated: " + login )
        records_updated = records_updated + 1
      end
      
      puts( "LDAP Import Complete: " + Time.now.to_s )
      puts( "Total Records Processed: " + records.to_s )
      puts( "Updated Records: " + records_updated.to_s ) 

      puts( "Updating records not in LDAP: " + Time.now.to_s )
      # For any users that are no longer in LDAP, copy the name column into last_name
      # and set first_name to "" so that we won't have any NULLs
      execute <<-SQL
        UPDATE users SET first_name = '', last_name = name WHERE last_name IS NULL
      SQL
      
      puts( "Update complete " + Time.now.to_s )

    rescue
      puts("There was a problem importing the data from LDAP.")
      raise
    end
    
    
  end

  def self.down
  end
end
