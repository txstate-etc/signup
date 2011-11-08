# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "log/cron_log.log"

if @environment == 'production'
  # send out email reminders for classes that are 3 days
  # out every night at 10:00pm.
  every '0 22 * * *' do
    rake "cron:send_reminders[3]"
  end

  # send out email reminders for classes that are today
  # every morning at 12:01am.
  every '1 0 * * *' do
    rake "cron:send_reminders[0]"
  end

  # send out survey emails
  # every morning at 12:10am.
  every '10 0 * * *' do
    rake "cron:send_surveys"
  end

  # update Users table nightly at 11:00pm
  every '0 21 * * *' do
    rake "cron:import_users"
  end
end