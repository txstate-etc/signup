# needed for csv exports of models
require 'csv'

module Signup
  class Engine < ::Rails::Engine
    # we don't want the generator to create coffee script files 
    config.generators do |g|
      g.javascript_engine :js
    end  

    # Make bower components part of our assets
    config.assets.paths << config.root.join('vendor', 'assets', 'components')

    # Asset precompile defaults to EVERYTHING. Since 3rd party libraries
    # often contain superfluous files, we want to whitelist
    # those extensions that we care about.
    # See: https://github.com/sstephenson/sprockets/issues/347
    initializer 'setup_asset_pipeline', :group => :all  do |app|
      # We don't want the default of everything that isn't js or css, because it pulls too many things in
      app.config.assets.precompile.shift

      # add the compiled css and js for our engine
      app.config.assets.precompile.push(/(?:\/|\\|\A)signup\.(css|js)$/)

      # Explicitly register the extensions we are interested in compiling
      app.config.assets.precompile.push(Proc.new do |path|
        File.extname(path).in? [
          '.html', '.erb', '.haml',                 # Templates
          '.png',  '.gif', '.jpg', '.jpeg', '.ico', # Images
          '.eot',  '.otf', '.svc', '.woff', '.ttf', # Fonts
        ]
      end)
    end
 
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
  end
end
