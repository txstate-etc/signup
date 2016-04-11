source 'https://rubygems.org'
ruby '2.1.5'

# Declare your gem's dependencies in signup.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# rical library for generating ics files
gem 'ri_cal', :github => 'txstate-etc/ri_cal', :ref => '5891733ef1'

group :development, :test do
  gem 'omniauth-cas', github: 'txstate-etc/omniauth-cas', ref: 'c2c538c371'
  gem 'thin'
end

group :development do
  gem 'better_errors'
  gem 'quiet_assets'
  
  # Shows stacktraces with amount of time spent in each function
  # add ?pp=flamegraph to display
  gem 'stackprof', '~> 0.2.7'
  gem 'flamegraph', '~> 0.0.5'
end
