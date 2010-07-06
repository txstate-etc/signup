require 'rubygems'
require 'rufus/scheduler'

scheduler = Rufus::Scheduler.start_new

# send out email reminders for classes that are 3 days
# out every night at 10:00pm.
scheduler.cron '0 22 * * *' do
  days_ahead = 3
  start_date = ( DateTime.now + days_ahead ).at_beginning_of_day
  end_date = ( DateTime.now + days_ahead ).end_of_day
  Session.send_reminders( start_date, end_date )
end

# send out email reminders for classes that are today
# every morning at 12:01am.
scheduler.cron '1 0 * * *' do
  days_ahead = 0
  start_date = ( DateTime.now + days_ahead ).at_beginning_of_day
  end_date = ( DateTime.now + days_ahead ).end_of_day
  Session.send_reminders( start_date, end_date )
end


# update Users table nightly at 11:00pm

scheduler.cron '0 21 * * *' do
  User.import_all
end