# Based on production defaults
require Rails.root.join("config/environments/production")

Rails.application.configure do
  # Put any custom staging settings here.

  # load testing controller
  config.routes_configuration_file = "#{RAILS_ROOT}/test/manual/config/routes.rb"
  ActiveSupport::Dependencies.autoload_paths << "#{RAILS_ROOT}/test/manual/controllers"

end
