unless Rails.env.production?

  require 'rake'

  class TestController < ApplicationController
    before_filter :authenticate

    def index
      redirect_to root_url and return unless authorized?
      
      @page_title = 'Test Actions'

      if params[:reminders0].present?
        run_rake 'mailer:send_reminders[0]'
        flash.now[ :notice ] = "Sent reminders for Today"
      elsif params[:reminders3].present?
        run_rake 'mailer:send_reminders[3]'
        flash.now[ :notice ] = "Sent reminders for 3 days out"
      elsif params[:followups].present?
        followups = save_followups do 
          run_rake 'mailer:send_followups'
        end
        restore_followups followups
        flash.now[ :notice ] = "Sent followups for #{followups.size} sessions"
      end

    end

    private

    def save_followups(&block)
      # get list of sessions that have survey_sent=false
      before = Session.where(survey_sent: false).pluck(:id)
      yield
      # get same list, return difference of two lists
      after = Session.uncached { Session.where(survey_sent: false).pluck(:id) }
      before - after
    end

    def restore_followups(followups)
      if followups.present?
        sessions = Session.find(followups)
        sessions.each do |s|
          s.survey_sent = false
          s.save!      
        end
      end
    end

    # def setup_view_path
    #   prepend_view_path "#{RAILS_ROOT}/test/manual/views"
    # end

    def run_rake(task)
      system "cd #{Rails.root} && RAILS_ENV=#{Rails.env} bundle exec rake #{task} --silent >> log/cron_log.log 2>&1"
    end
  end

end
