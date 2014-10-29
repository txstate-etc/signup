# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'signup'

set :repo_url, 'https://projects.its.txstate.edu/hg/registerme'
set :branch, 'rails-4'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

set :user, 'rubyapps'

set :ssh_options, { user: fetch(:user) }

# Set rvm version to the same as we use in development
set :rvm_ruby_version, "#{IO.read('.ruby-version').chomp}@#{IO.read('.ruby-gemset').chomp}"

# Default deploy_to directory is /var/www/my_app
set :deploy_to, "/home/#{fetch(:user)}/#{fetch(:application)}"

# Default value for :scm is :git
set :scm, :hg

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/secrets.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{backups log tmp/pids public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

before 'deploy', 'rvm1:install:rvm'
before 'deploy', 'rvm1:install:ruby'

after 'deploy:publishing', 'delayed_job:restart'

after 'deploy:finished', 'static:generate'

# Deploy to training after successfully deploying to production
if fetch(:stage) == :production
  after 'deploy:finished' do
    puts "Deploying to 'training'"
    exec "cap training deploy"
  end
end
