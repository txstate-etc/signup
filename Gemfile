source 'https://rubygems.org'
ruby '2.1.2'
gem 'rails', '~> 4.1.6'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 2.5.3'
gem 'coffee-rails', '~> 4.0.1'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.1.3'
gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'spring',        group: :development
gem 'mysql2'
gem 'simple_form'

# Make $(document).ready work with turbolinks
gem 'jquery-turbolinks'

# add cache of association counts
# more flexibly than the builtin version
gem 'counter_culture', '~> 0.1.25'

# convert urls in descriptions into links
# Won't need this after implementing wysiwyg editor.
gem 'rails_autolink'

# Tags!
gem 'acts-as-taggable-on'

# Attachments/Documents
gem 'paperclip', '~> 4.2.0'

# Nested form helpers (for attachments, instructors, etc)
gem 'cocoon'

# CAS authentication - need github branch for single signout support
gem 'omniauth-cas', :git => 'https://github.com/dlindahl/omniauth-cas.git'

# LDAP user lookups
gem 'net-ldap'

# Autocomplete for instructors, etc.
# despite the name, should work on rails 4
gem 'rails3-jquery-autocomplete'

# used by HtmlToPlainText
gem 'htmlentities'

# rical library for generating ics files
gem 'ri_cal', :github => 'chuckbjones/ri_cal', :branch => 'master'

# Use tags instead of keys to expire large swaths of cached pages/fragments at once
gem 'cashier'

# render pdf documents from ruby code
gem 'prawn'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_21]
  gem 'quiet_assets'
  gem 'rails_layout'
end

group :development, :test do
  gem 'thin'
end
