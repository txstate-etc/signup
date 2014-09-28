require "#{RAILS_ROOT}/config/routes.rb"

ActionController::Routing::Routes.draw do |map|
  map.connect 'test', :controller => :test, :action => :index
end
