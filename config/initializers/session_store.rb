# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_registerme_session',
  :secret      => 'f14sta7416b272fcd67e1e116ad11fbf1c2f2614a6df6710c47b9844ba1e31bf95b2720d43302973bfa2b7106e638d736761999d083cda9b85680811fcc1cda4fb53a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
