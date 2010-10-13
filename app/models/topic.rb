require 'fastercsv'

class Topic < ActiveRecord::Base
  has_many :sessions
  validates_presence_of :name, :description, :minutes
  
  def upcoming_sessions
    sessions.find( :all, :conditions => [ "time > ? AND cancelled = false", Time.now ] )
  end
  
  def to_csv
    FasterCSV.generate do |csv|
      csv << [ "Topic", "Session ID", "Session Time", "Session Cancelled", "Attendee Name", "Attendee Login", "Attendee Email", "Reservation Confirmed?" ]
      logger.info "FOO: STarting iterations"
      sessions.each do |session|
        logger.info "FOO: session - " + session.topic.name
        session.reservations.each do |reservation|
          logger.info "FOO: reservation - " + reservation.user.name
          csv << [ session.topic.name, session.id, session.time, session.cancelled, reservation.user.name, reservation.user.login, reservation.user.email, reservation.confirmed? ]
        end
      end
    end
  end
  
  def survey_responses
    Reservation.all(:joins => [ :survey_response, :session ], :include => [ :survey_response, :session ], :conditions => [ 'topic_id = ?', self ] ).collect{|reservation| reservation.survey_response}
  end
end
