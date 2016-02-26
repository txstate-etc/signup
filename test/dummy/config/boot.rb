# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
$LOAD_PATH.unshift File.expand_path('../../../../lib', __FILE__)

DEFAULT_SERVER_PORT = 5656

# set default port for dev server
require 'rails/commands/server'
module Rails
  class Server
    def default_options
      super.merge({
        :Port => DEFAULT_SERVER_PORT
      })
    end
  end
end
