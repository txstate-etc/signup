source 'https://rubygems.org'
ruby '2.1.5'
gem 'rails', '~> 4.1.8'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 2.5.3'
gem 'jquery-rails', '~> 3.1.2'
gem 'jbuilder', '~> 2.2.4'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'spring', '~> 1.1.3', group: :development
gem 'mysql2', '~> 0.3.16'
gem 'simple_form', '~> 3.0.2'

# Needed to precompile assets
gem "therubyracer", '~> 0.12.1'

# add cache of association counts
# more flexibly than the builtin version
gem 'counter_culture', '~> 0.1.25'

# convert urls in descriptions into links
# Won't need this after implementing wysiwyg editor.
gem 'rails_autolink', '~> 1.1.6'

# Tags!
gem 'acts-as-taggable-on', '~> 3.4.2'

# Attachments/Documents
gem 'paperclip', '~> 4.2.0'

# Nested form helpers (for attachments, instructors, etc)
gem 'cocoon', '~> 1.2.6'

# CAS authentication - need github branch for single signout support
#gem 'omniauth-cas', :github => 'dlindahl/omniauth-cas', :ref => '43ee3f25'
gem 'omniauth-cas', :github => 'chuckbjones/omniauth-cas', :branch => 'master'

# LDAP user lookups
gem 'net-ldap', '~> 0.9.0'

# Autocomplete for instructors, etc.
# despite the name, should work on rails 4
gem 'rails3-jquery-autocomplete', '~> 1.0.14'

# used by HtmlToPlainText
gem 'htmlentities', '~> 4.3.2'

# rical library for generating ics files
gem 'ri_cal', :github => 'chuckbjones/ri_cal', :branch => 'master'

# Use tags instead of keys to expire large swaths of cached pages/fragments at once
gem 'cashier', '~> 0.4.1'

# render pdf documents from ruby code
gem 'prawn', '~> 1.3.0'

# sends emails in a background process and retries when they fail
gem 'daemons', '~> 1.1.9'
gem 'delayed_job', '~> 4.0.4'
gem 'delayed_job_active_record', '~> 4.0.2'

# run cron jobs
gem 'whenever', '~> 0.9.4'

# email errors to us.
gem 'exception_notification', '~> 4.0.1'

# generate static pages
gem 'high_voltage', '~> 2.2.1'

# audit model changes
gem 'paper_trail', '~> 3.0.6'

# performance profiler
gem 'rack-mini-profiler', '~> 0.9.2'

# Shows stacktraces with amount of time spent in each function
# add ?pp=flamegraph to display
gem 'stackprof', '~> 0.2.7'
gem 'flamegraph', '~> 0.0.5'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_21]
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'capistrano', '~> 3.3.3', require: false
  # gem 'capistrano-rvm', '~> 0.1', require: false
  gem 'capistrano-rails', '~> 1.1.2', require: false
  gem 'capistrano-bundler', '~> 1.1.3', require: false
  gem 'capistrano-passenger', '~> 0.0.1', require: false
  gem 'rvm1-capistrano3', require: false
  gem 'traceroute'
  gem 'bullet'
end

group :development, :test do
  gem 'thin'
end
