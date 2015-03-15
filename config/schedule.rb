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

job_type :bin,  "cd :path && :environment_variable=:environment :bundle_command bin/:task :output"

set :output, "log/cron_log.log"

# start the delayed_job daemon when the system reboots
every :reboot do
  bin "delayed_job start"
end

# restart the delayed_job daemon if it looks like it is not responding
every 4.minutes do
  runner "require 'delayed_job_util'; DelayedJobUtil.health_check"
end

# send out email reminders for classes that are 3 days
# out every night at 10:02pm.
every :day, at: '10:02 pm' do
  rake "mailer:send_reminders[3]"
end

# send out email reminders for classes that are today
# every morning at 12:02am.
every :day, at: '12:02 am' do
  rake "mailer:send_reminders[0]"
end

# send out followup emails
# every morning at 12:10am.
every :day, at: '12:10 am' do
  rake "mailer:send_followups"
end

# backup database nightly at 2:30am
every :day, at: '2:30 am' do
  rake "db:backup MAX=30"
end

# clean up old http_sessions nightly at 2:40am
every :day, at: '2:40 am' do
  rake "db:session_clean DAYS=30"
end

# Cleanup and Prewarm the File-based cache store nightly at 1am.
# Deletes all items that have expired (30 days old).
# Warms the cache for today's entries.
every :day, :at => '1:05 am' do
  runner "Rails.cache.cleanup"
  rake "cache:warm"
end
