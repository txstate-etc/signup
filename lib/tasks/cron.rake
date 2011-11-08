# lib/tasks/cron.rake
# Tasks to be run periodically by cron, using the whenever gem

namespace :cron do
  
  desc "Send out email reminders for classes that are N days out"
  task :send_reminders, [:days_ahead] => :environment do |t, args|
    days_ahead = args.days_ahead.to_i
    start_date = ( DateTime.now + days_ahead ).at_beginning_of_day
    end_date = ( DateTime.now + days_ahead ).end_of_day
    Session.send_reminders( start_date, end_date )    
  end

  desc "Send out survey emails"
  task :send_surveys => :environment do 
    Session.send_surveys   
  end

  desc "Update Users table"
  task :import_users => :environment do 
    User.import_all
  end

end

