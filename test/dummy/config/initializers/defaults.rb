ORG_URL = 'http://www.txstate.edu/'
DIRECTORY_URL_BASE = 'http://peoplesearch.txstate.edu/peoplesearch.pl?srchmode=search&query=userid%3D##LOGIN##'

BASE_DN = "DC=matrix,DC=txstate,DC=edu"
BIND_DN = "CN=sa-ldap-its,OU=Service Accounts,OU=TxState Objects,#{BASE_DN}"
BIND_PASS = Rails.application.secrets.ldap_password
USER_BASE = "ou=TxState Users,#{BASE_DN}"
QUERY_BASE = "(objectCategory=CN=Person,CN=Schema,CN=Configuration,#{BASE_DN})"
LDAP_SERVERS = ['ldap.txstate.edu']
MAIL_DOMAIN = 'txstate.edu'
