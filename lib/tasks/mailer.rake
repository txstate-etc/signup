namespace :mailer do
  
  desc "Send out email reminders for classes that are N days out"
  task :send_reminders, [:days_ahead] => :environment do |t, args|
    days_ahead = args[:days_ahead].to_i
    only_first_occurrence = days_ahead > 0 # Only send reminder for the first occurrence of a session unless the reminder is for today's occurrence
    start_date = ( DateTime.now + days_ahead ).at_beginning_of_day
    end_date = ( DateTime.now + days_ahead ).end_of_day
    Session.send_reminders( start_date, end_date, only_first_occurrence )    
    Rails.logger.flush
  end

  desc "Send out followup emails"
  task :send_followups => :environment do 
    Session.send_followups   
    Rails.logger.flush
  end

end
