namespace :cache do
  
  desc "Preload the most used and heaviest cache pages"
  task warm: :environment do 
    ApplicationController.class_eval do
      def current_user
        @_current_user ||= User.where(admin: true).first
      end
    end

    require "rails/console/app"
    require "rails/console/helpers"
    extend Rails::ConsoleMethods

    app.host = ActionMailer::Base.default_url_options[:host] || 'localhost'
    port = ActionMailer::Base.default_url_options[:port] || nil
    app.host += ":#{port}" if port
    
    print "Warming cache for root url: "
    puts app.get '/'

    # get all of the variations of the upcoming topics listing
    %w{ by-department by-site alpha grid }.each do |action|
      print "Warming cache for /topics/#{action}: "
      puts app.get("/topics/#{action}")
    end

    print "Warming cache for /topics/manage: "
    puts app.get("/topics/manage?topics=all&departments=all")

    # get the ics file for all upcoming sessions
    print "Warming cache for sessions/download: "
    puts app.get('/sessions/download')
    
    # do a year's worth of grids
    date = 6.months.ago.beginning_of_month.to_date
    12.times do 
      print "Warming cache for topics/grid/#{date.strftime('%Y/%m')}: "
      puts app.get("/topics/grid/#{date.strftime('%Y/%m')}")
      date >>= 1
    end

    # get the manage topic pages
    Topic.active.each do |t|
      print "Warming cache for topics/#{t.to_param}/history: "
      puts app.get("/topics/#{t.to_param}/history")
      print "Warming cache for topics/#{t.to_param}.csv: "
      puts app.get("/topics/#{t.to_param}.csv")      
      print "Warming cache for topics/#{t.to_param}.atom: "
      # @request.env['REQUEST_URI'] = nil
      puts app.get("/topics/#{t.to_param}.atom")      
      print "Warming cache for topics/#{t.to_param}.ics: "
      puts app.get("/topics/#{t.to_param}.ics")      
    end

    # get the departments
    print "Warming cache for /departments: "
    puts app.get("/departments")      
    Department.active.each do |d|
      print "Warming cache for departments/#{d.to_param}: "
      puts app.get("/departments/#{d.to_param}")      
      print "Warming cache for departments/#{d.to_param}.csv: "
      puts app.get("/departments/#{d.to_param}.csv")      
      print "Warming cache for departments/#{d.to_param}.atom: "
      # @request.env['REQUEST_URI'] = nil
      puts app.get("/departments/#{d.to_param}.atom")      
    end

    # get the tags
    ActsAsTaggableOn::Tag.all.each do |t| 
      print "Warming cache for tags/#{t.name}: "
      puts app.get("/tags/#{t.name}")      
      print "Warming cache for tags/#{t.name}.csv: "
      puts app.get("/tags/#{t.name}.csv")      
      print "Warming cache for tags/#{t.name}.atom: "
      # @request.env['REQUEST_URI'] = nil
      puts app.get("/tags/#{t.name}.atom")      
    end

    # FIXME: would be nice to cache the manage* pages with an unauthorized user

  end

end
