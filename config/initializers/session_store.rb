# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_joruri_cms_session',
  :secret      => 'd9e481081a4551490639b7cf05d65d017818db8417560e9e22b00b61e3778cd2d61d42bf21efb06a2fe5323c7932967c4344e08fc9b02737ee3982f1324d456a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
