source 'https://rubygems.org'
ruby '2.1.2'
gem 'rails', '4.1.1'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'spring',        group: :development
gem 'mysql2'
gem 'simple_form'

# Make $(document).ready work with turbolinks
gem 'jquery-turbolinks'

# add cache of association counts
# more flexibly than the builtin version
gem 'counter_culture', '~> 0.1.18'

# convert urls in descriptions into links
# Won't need this after implementing wysiwyg editor.
gem 'rails_autolink'

# Tags!
gem 'acts-as-taggable-on'

# Attachments/Documents
gem 'paperclip', '~> 4.1'

# Nested form helpers (for attachments, instructors, etc)
gem 'cocoon'

# CAS authentication - need github branch for single signout support
gem 'omniauth-cas', :git => 'https://github.com/dlindahl/omniauth-cas.git'

# LDAP user lookups
gem 'net-ldap'

# Autocomplete for instructors, etc.
# despite the name, should work on rails 4
gem 'rails3-jquery-autocomplete'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_21]
  gem 'quiet_assets'
  gem 'rails_layout'
end

group :development, :test do
  gem 'thin'
end
