require 'rake'

class TestController < ApplicationController
  before_filter :authenticate
  before_filter :setup_view_path

  def index
    redirect_to root_url and return unless authorized?
    
    if params[:reminders0].present?
      run_rake 'cron:send_reminders[0]'
      flash.now[ :notice ] = "Sent reminders for Today"
    elsif params[:reminders3].present?
      run_rake 'cron:send_reminders[3]'
      flash.now[ :notice ] = "Sent reminders for 3 days out"
    elsif params[:followups].present?
      followups = save_followups do 
        run_rake 'cron:send_followups'
      end
      restore_followups followups
      flash.now[ :notice ] = "Sent followups for #{followups.size} sessions"
    end

  end

  private

  def save_followups(&block)
    # get list of sessions that have survey_sent=false
    before = Session.all(:conditions => {:survey_sent => false}).map(&:id)
    yield
    # get same list, return difference of two lists
    after = Session.uncached { Session.all(:conditions => {:survey_sent => false}).map(&:id) }
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

  def setup_view_path
    prepend_view_path  "#{RAILS_ROOT}/test/manual/views"
  end

  def run_rake(task)
    system "cd #{RAILS_ROOT} && RAILS_ENV=#{RAILS_ENV} bundle exec rake #{task} --silent >> log/cron_log.log 2>&1"
  end
end
