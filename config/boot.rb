# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

# set default port for dev server
require 'rails/commands/server'
module Rails
  class Server
    def default_options
      super.merge({
        :Port => 5656
      })
    end
  end
end
