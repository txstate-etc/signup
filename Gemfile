source 'https://rubygems.org'
ruby '2.1.3'
gem 'rails', '~> 4.1.6'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 2.5.3'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.1.3'
gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'spring',        group: :development
gem 'mysql2'
gem 'simple_form'

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

# sends emails in a background process and retries when they fail
gem 'daemons'
gem 'delayed_job'
gem 'delayed_job_active_record'

# run cron jobs
gem 'whenever'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_21]
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'capistrano', '~> 3.0', require: false
  gem 'capistrano-rvm', '~> 0.1', require: false
  gem 'capistrano-rails', '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-passenger', '~> 0.0.1', require: false
end

group :development, :test do
  gem 'thin'
end
