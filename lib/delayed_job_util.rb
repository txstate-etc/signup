class DelayedJobUtil
  def self.health_check
    count = Delayed::Job.where('created_at < ? AND failed_at IS NULL', 10.minutes.ago).count
    if count > 0
      # restart delayed_job and send an email
      Rails.logger.error("There are #{count} outstanding delayed_jobs. restarting daemon.")
      ExceptionNotifier.notify_exception(Exception.new('delayed_job error')) if Rails.env == "production"
      Rails.logger.info `/usr/bin/env RAILS_ENV=#{Rails.env} bundle exec bin/delayed_job restart`
    end
  end
end
