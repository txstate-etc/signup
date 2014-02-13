ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "topics"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'

  map.attendance 'sessions/attendance/:id.:format', :controller => :sessions, :action => :attendance
  map.connect 'sessions/download', :controller => :sessions, :action => :download
  map.connect 'sessions/email/:id', :controller => :sessions, :action => :email
  map.connect 'topics/download/:id', :controller => :topics, :action => :download
  map.connect 'topics/filter/*filter', :controller => :topics, :action => :filter
  map.connect 'topics/by-department', :controller => :topics, :action => :by_department
  map.connect 'topics/by-site', :controller => :topics, :action => :by_site
  map.connect 'topics/upcoming', :controller => :topics, :action => :upcoming
  map.connect 'topics/grid/:year/:month', :controller => :topics, :action => :grid, :defaults => { :year => nil, :month => nil }
  map.login 'login', :controller => :authentication, :action => :login
  map.logout 'logout', :controller => :authentication, :action => :logout

  map.resources :departments, :collection => { :manage => :get }
  map.resources :users, :except => [:show], :collection => { :search => :get } 
  map.resources :tags, :only => :show

  map.resources :topics, :shallow => true, :member => { :delete => :get }, :collection => { :manage => :get } do |topic|
    topic.resources :sessions do |session|
      session.resources :reservations, :create 
    end
  end

  map.resources :reservations, :only => :edit
  map.reservations 'reservations', :controller => :reservations, :action => :index
  
  map.connect 'reservations/download/:id', :controller => :reservations, :action => :download
  map.send_reminder 'reservations/send_reminder/:id', :controller => :reservations, :action => :send_reminder
  map.resources :survey_responses, :only => [ :create ]
  map.new_survey_response 'survey_responses/new', :controller => :survey_responses, :action => :new
  map.topic_survey_results 'topics/:id/survey_results', :controller => :topics, :action => :survey_results
  map.session_survey_results 'sessions/:id/survey_results', :controller => :sessions, :action => :survey_results
end
