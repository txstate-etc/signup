namespace :migrate do

  ## How to import data from production to dev and staging ##
  # * make sure lib/tasks/mysqldump.rake is on production and staging (Rails 2 app)
  # * on dev (Rails 2 app):
  #     - run `KEEPDUMP=1 cap production data:import`
  #     - run `cap staging data:send_dump`
  # * on dev (new app): 
  #     - run `OLD_RAILS_ROOT="<full absolute path to rails 2 app>" rake migrate:all`
  # * on staging (new app):
  #     - run `RAILS_ENV=staging bundle exec rake migrate:all`
  #     - run `RAILS_ENV=staging bundle exec rake cache:warm`

  desc "Migrate database and documents"
  task all: [:environment, 'migrate:data', 'migrate:documents']

  desc "Migrate attachments from old PaperClip format to new."
  task :documents => [:environment] do
    path_to_old_items = "#{old_documents_root}/items"

    puts "Migrating document from #{path_to_old_items} to #{path_to_documents}"

    Document.all.each do |d|
      new_file = Pathname.new d.item.path
      old_file = Pathname.new "#{path_to_old_items}/#{d.id}/original/#{d.item_file_name}"

      if !old_file.exist?
        puts "Can't find old file: #{old_file}"
        next
      end

      puts "Copying #{old_file} to #{new_file}"
      FileUtils.mkdir_p new_file.dirname
      FileUtils.cp old_file.to_s, new_file.to_s
    end

    # Copy the old documents so old links still work.
    FileUtils.cp_r path_to_old_items, path_to_documents

  end

  desc "Migrate data from Rails 2 application to this one."
  task data: [:environment, 'db:reset'] do
    init_db_params

    # import all tables except users (that one requires special handling)
    %w(
      departments
      documents
      occurrences
      permissions
      reservations
      sessions
      sessions_users
      sites
      survey_responses
      taggings
      tags
      topics
    ).each { |t| import_table(t) }

    # Only import into users into the new system that had their 'active' flag set
    # We don't have an active flag in the new app, but I'm not smart enough to figure out how to
    # import the data without it, so we'll add it here, then remove it right after.
    update_active_user_count
    `mysql -u #{@to_db_user} --password=#{@to_db_pass} #{@to_db} -e'ALTER TABLE users ADD active tinyint'`
    import_table('users', 'active=1')
    `mysql -u #{@to_db_user} --password=#{@to_db_pass} #{@to_db} -e'ALTER TABLE users DROP active'`

    # initialize association count cache
    Reservation.counter_culture_fix_counts
    ActsAsTaggableOn::Tag.reset_column_information
    ActsAsTaggableOn::Tag.find_each do |tag|
      ActsAsTaggableOn::Tag.reset_counters(tag.id, :taggings)
    end

    Rails.cache.clear
  end

  task update_active_user_count: [:environment] do
    init_db_params
    update_active_user_count
  end

  private

  def update_active_user_count
    puts 'Updating active user count...'
    
    # first clear active flag for everyone
    `mysql -u #{@from_db_user} --password=#{@from_db_pass} #{@from_db} -e'update users set active=0;'`
    
    # now set the active flag for anyone who has actually used the system, i.e.,
    # anyone who has made a reservation or is an editor, instructor, or admin.
    command = <<-END
      update users
        join (select user_id from reservations union 
               select user_id from permissions union 
               select user_id from sessions_users union 
               select id as user_id from users where admin=1
             ) list on
       users.id = list.user_id
      set
        active = 1
    END

    `mysql -u #{@from_db_user} --password=#{@from_db_pass} #{@from_db} -e'#{command.gsub(/\s+/, ' ')}'`
  end

  def init_db_params
    db_config = Rails.configuration.database_configuration[Rails.env]
    @to_db = db_config['database']
    @to_db_user = db_config['username']
    @to_db_pass = db_config['password']

    @from_db = db_config['database'].gsub(/signup/, 'registerme')
    @from_db_user = db_config['username']
    @from_db_pass = db_config['password']

    # User and pass are probably not the same as in new app
    # Need to find and parse auth.rb from old app
    auth_file = "#{old_rails_root}/config/initializers/auth.rb"
    found = require auth_file if File.exist? auth_file
    puts "File not found: #{auth_file}" unless found      
    if defined? MYSQL_USER
      @from_db_user = MYSQL_USER
      puts "Using from_db_user=#{@from_db_user} from #{auth_file}"
    end
    if defined? MYSQL_PASSWORD
      @from_db_pass = MYSQL_PASSWORD
      puts "Using from_db_pass from #{auth_file}"
    end
  end

  def import_table(table, where='')
      puts "Importing #{table} ......"

      dump_opts = '--default-character-set=utf8 --skip-set-charset --no-create-info --complete-insert'
      dump_opts << " --where #{where}" if where.present?

      `mysqldump -u #{@from_db_user} --password=#{@from_db_pass} #{dump_opts} #{@from_db} #{table} > #{table}.sql`
      `mysql -u #{@to_db_user} --password=#{@to_db_pass} --default-character-set=utf8 #{@to_db} < #{table}.sql`

  end

  def old_rails_root
    if Rails.env.development?
      if ENV['OLD_RAILS_ROOT']
        Pathname.new ENV['OLD_RAILS_ROOT']
      else
        abort('OLD_RAILS_ROOT not defined')
      end
    else
      Rails.root.join('../../current').sub('signup','registerme')
    end
  end

  def old_documents_root
    if Rails.env.development?
      old_rails_root + 'public/system'
    else
      old_rails_root + '../shared/system'
    end
  end

  def path_to_documents
    if Rails.env.development?
      Rails.root + 'public/system'
    else
      Rails.root + '../../shared/system'
    end
  end

end
