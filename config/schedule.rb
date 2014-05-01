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

env :PATH, '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

job_type :envcommand, 'cd :path && RAILS_ENV=:environment :task'

set :output, "log/cron_log.log"

# send out email reminders for classes that are 3 days
# out every night at 10:02pm.
every '2 22 * * *' do
  rake "cron:send_reminders[3]"
end

# send out email reminders for classes that are today
# every morning at 12:02am.
every '2 0 * * *' do
  rake "cron:send_reminders[0]"
end

# send out followup emails
# every morning at 12:10am.
every '10 0 * * *' do
  rake "cron:send_followups"
end

# update Users table nightly at 11:02pm
every '2 21 * * *' do
  rake "cron:import_users"
end

# backup database nightly at 2:30am
every '30 2 * * *' do
  rake "db:backup MAX=30"
end

# clean up old http_sessions nightly at 2:40am
every '40 2 * * *' do
  rake "db:session_clean DAYS=30"
end

# restart the delayed_job daemon when the system reboots
every :reboot do
  rake "cron:delayed_job:restart"
end

every 1.hour do
  rake "cron:delayed_job:restart"
end

# Cleanup and Prewarm the File-based cache store nightly at 1am.
# Deletes any datestamped directories older than today.
# Deletes all other items that haven't been accessed in 30 days.
# Warms the cache for today's entries.
every :day, :at => '1:05 am' do
  rake "cache:prune_dates"
  rake "cache:cleanup[30]"
  rake "cache:warm"
end
