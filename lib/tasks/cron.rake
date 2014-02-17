# lib/tasks/cron.rake
# Tasks to be run periodically by cron, using the whenever gem

namespace :cron do
  
  desc "Send out email reminders for classes that are N days out"
  task :send_reminders, [:days_ahead] => :environment do |t, args|
    days_ahead = args.days_ahead.to_i
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

  desc "Update Users table"
  task :import_users => :environment do 
    User.import_all
    Rails.logger.flush
  end

  namespace :delayed_job do
    
    def get_pid
      begin
        IO.read("#{RAILS_ROOT}/tmp/pids/delayed_job.pid").to_i
      rescue
        nil
      end
    end
    
    def pid_exists?(pid) 
      return false if pid.nil?
      begin
        Process.getpgid( pid )
        true
      rescue Errno::ESRCH
        false
      end
    end
    
    desc "Stop delayed_job daemon"
    task :stop => :environment do
      pid = get_pid
      
      # stop
      puts "Stopping..."
      STDOUT.flush
      `cd #{RAILS_ROOT} && RAILS_ENV=#{Rails.env} script/delayed_job stop`
      sleep 5
      puts "Stop finished"
      STDOUT.flush
      
      # check pid, kill -SIGKILL if necessary
      puts "pid to kill is #{pid}"
      STDOUT.flush
      if pid_exists?(pid)
        puts "pid to kill, #{pid}, exists. Killing..."
        STDOUT.flush
        Process.kill("KILL", pid)
        puts "Killed #{pid}, sleeping 5 seconds"
        STDOUT.flush
        sleep 5
        puts "Done sleeping"
        STDOUT.flush
      end
    end

    desc "Start delayed_job daemon if not already running"
    task :start => :environment do
      # check pid, start if not running
      pid = get_pid
      puts "checking #{pid} before starting"
      STDOUT.flush
      if pid_exists?(pid)
        puts "Pid #{pid} exists, not starting"
        STDOUT.flush
      else
        puts "Pid #{pid} does not exist. Starting..."
        STDOUT.flush
        `cd #{RAILS_ROOT} && RAILS_ENV=#{Rails.env} script/delayed_job start` unless pid_exists?(get_pid)
      end
    end

    desc "Restart delayed_job daemon"
    task :restart => [:environment, :stop, :start] 
  end
  
  task :checkenv => :environment do
    puts "root is #{RAILS_ROOT}"
    puts "environment is #{RAILS_ENV}"
    puts "also #{Rails.env}"
    puts `echo $RAILS_ENV`
  end
end

