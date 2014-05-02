namespace :cache do
  
  desc "Preload the most used and heaviest cache pages"
  task :warm => :environment do 
    include ActionController::TestProcess
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new

    # first, set current_user to an admin
    user = User.first(:conditions => { :admin => true })
    @request.session[:user] = user.id.to_s
    @request.session[:topics] = 'all'
    @request.session[:departments] = 'all'

    # get all of the variations of the upcoming topics listing
    %w{ index by_department by_site alpha grid manage }.map(&:to_sym).each do |action|
      @controller = TopicsController.new
      print "Warming cache for topics/#{action}: "
      puts get(action).status
    end

    # get the ics file for all upcoming sessions
    @controller = SessionsController.new
    print "Warming cache for sessions/download: "
    puts get(:download).status
    

    # do a year's worth of grids
    date = 6.months.ago.beginning_of_month.to_date
    12.times do 
      @controller = TopicsController.new
      print "Warming cache for topics/grid/#{date.strftime('%Y/%m')}: "
      puts get(:grid, :year => date.year, :month => date.month).status
      date >>= 1
    end

    # get the manage topic pages
    Topic.active.each do |t|
      @controller = TopicsController.new
      print "Warming cache for topics/manage/#{t.to_param}: "
      puts get(:manage_topic, :id => t.id).status      
      print "Warming cache for topics/#{t.to_param}.csv: "
      puts get(:show, :id => t.id, :format => 'csv').status      
      print "Warming cache for topics/#{t.to_param}.atom: "
      puts get(:show, :id => t.id, :format => 'atom').status      
      print "Warming cache for topics/#{t.to_param}.ics: "
      puts get(:download, :id => t.id).status      
    end

    # get the departments
    @controller = DepartmentsController.new
    print "Warming cache for /departments: "
    puts get(:index).status      
    Department.active.each do |d|
      @controller = DepartmentsController.new
      print "Warming cache for departments/#{d.to_param}: "
      puts get(:show, :id => d.id).status      
      print "Warming cache for departments/#{d.to_param}.csv: "
      puts get(:show, :id => d.id, :format => 'csv').status      
      print "Warming cache for departments/#{d.to_param}.atom: "
      puts get(:show, :id => d.id, :format => 'atom').status      
    end

    # get the tags
    ActsAsTaggableOn::Tag.all.each do |t| 
      @controller = TagsController.new
      print "Warming cache for tags/#{t.name}: "
      puts get(:show, :id => t.name).status      
      print "Warming cache for tags/#{t.name}.csv: "
      puts get(:show, :id => t.name, :format => 'csv').status      
      print "Warming cache for tags/#{t.name}.atom: "
      puts get(:show, :id => t.name, :format => 'atom').status      
    end

    # FIXME: would be nice to cache the manage* pages with an unauthorized user

  end


  desc "Delete datestamped cache directories older than today"
  task :prune_dates => :environment do |t|
    today = Date.today
    base = "#{Rails.cache.cache_path}/views"
    return if !File.exist?(base)
    Dir.foreach(base) do |d|
      next unless d =~ /^\d{4}-\d{2}-\d{2}$/
      next unless Date.parse(d) < today
      name = File.join(base, d)
      FileUtils.remove_entry_secure(name)
    end
  end

  desc "Delete cache entries that haven't been accessed in N days"
  task :cleanup, [:not_accessed_in] => :environment do |t, args|
    timestamp = Time.now - (args.not_accessed_in.to_i || 1).days.to_i
    search_dir(Rails.cache.cache_path) do |fname|
      atime = File.atime(fname)
      if atime <= timestamp 
        File.delete(fname)
        delete_empty_directories(File.dirname(fname))
      end
    end
  end

  EXCLUDED_DIRS = ['.', '..'].freeze

  # From https://github.com/rails/rails/blob/3-2-stable/activesupport/lib/active_support/cache/file_store.rb
  def search_dir(dir, &callback)
    return if !File.exist?(dir)
    Dir.foreach(dir) do |d|
      next if EXCLUDED_DIRS.include?(d)
      name = File.join(dir, d)
      if File.directory?(name)
        search_dir(name, &callback)
      else
        callback.call name
      end
    end
  end

  # Delete empty directories in the cache.
  # See: https://github.com/rails/rails/pull/9329
  def delete_empty_directories(dir)
    return if Pathname.new(dir).realpath == Pathname.new(Rails.cache.cache_path).realpath
    if Dir.entries(dir).reject {|f| EXCLUDED_DIRS.include?(f)}.empty?
      Dir.delete(dir) rescue nil
      delete_empty_directories(File.dirname(dir))
    end
  end
end
