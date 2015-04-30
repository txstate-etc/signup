namespace :db do  
  # USAGE
  # =====
  # rake db:backup
  # RAILS_ENV=production rake db:backup
  # MAX=14 RAILS_ENV=production rake db:backup
  # DIR=another_dir MAX=14 RAILS_ENV=production rake db:backup
  # adapted from https://gist.github.com/772743
  desc "Backup project database. Options: DIR=backups RAILS_ENV=production MAX=7" 
  task backup: :environment do
    datestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")    
    base_path = ENV["DIR"] || "backups"
    base_path = File.join(Rails.root, base_path) unless base_path == File.expand_path(base_path)
    backup_base = File.join(base_path, 'db_backups')
    backup_folder = File.join(backup_base, datestamp)
    backup_file = File.join(backup_folder, "#{Rails.env}_dump.sql")    
    FileUtils.mkdir_p(backup_folder)    
    db_config = Rails.configuration.database_configuration[Rails.env]
    `mysqldump -u #{db_config['username']} -p#{db_config['password']} -i -c -q #{db_config['database']} > #{backup_file}`
    raise "Unable to make DB backup!" if ( $?.to_i > 0 )
    `gzip -9 #{backup_file}`
    dir = Dir.new(backup_base)
    all_backups = dir.entries.sort[2..-1].reverse
    puts "Created backup: #{backup_file}"     
    max_backups = (ENV["MAX"].to_i if ENV["MAX"].to_i > 0) || 7
    unwanted_backups = all_backups[max_backups..-1] || []
    for unwanted_backup in unwanted_backups
      FileUtils.rm_rf(File.join(backup_base, unwanted_backup))
    end
    puts "Deleted #{unwanted_backups.length} backups, #{all_backups.length - unwanted_backups.length} backups available" 
  end
  
  desc "Delete old sessions. Options: DAYS=30" 
  task session_clean: :environment do
    age = (ENV["DAYS"].to_i if ENV["DAYS"].to_i > 0) || 30
    date = age.days.ago.utc.beginning_of_day.to_date    
    AuthSession.where('updated_at < ?', date).delete_all
  end
  
  desc "Dump mysql data to file."
  task :dump => :environment do
    `tar zcvf #{Rails.root}/tmp/documents.signup.tar.gz  -C #{Rails.root}/public/system documents`
    config = Rails.configuration.database_configuration[Rails.env]
    `mysqldump -u #{config['username']} --password=#{config['password']} #{config['database']} > #{Rails.root}/tmp/dump.signup.sql`
  end
  
  desc "Import mysql data from file."
  task :fromdump => :environment do
    if (Rails.env == "production")
      puts "Never run this in production!"
    else
      config = Rails.configuration.database_configuration[Rails.env]
      `mysql -u #{config['username']} --password=#{config['password']} -e "DROP DATABASE IF EXISTS #{config['database']}; CREATE DATABASE #{config['database']}"`
      `mysql -u #{config['username']} --password=#{config['password']} #{config['database']} < #{Rails.root}/tmp/dump.signup.sql`
      `mkdir -p #{Rails.root}/public/system`
      `tar zxvf #{Rails.root}/tmp/documents.signup.tar.gz -C #{Rails.root}/public/system`

      # reset association count caches and clear view caches
      Reservation.counter_culture_fix_counts
      ActsAsTaggableOn::Tag.reset_column_information
      ActsAsTaggableOn::Tag.find_each do |tag|
        ActsAsTaggableOn::Tag.reset_counters(tag.id, :taggings)
      end

      Rails.cache.clear
    end
  end
end
