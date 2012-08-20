# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_registerme_session',
  :secret      => '075e90073593c1f617a7e52ae4b7713ee9d6b5113f805044799e2729bf08c9c4b3bd4cbb7ad5f57ab0e49c89a310dda3be949cde868d7de070eb76cc9989d5c5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
