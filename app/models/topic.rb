require 'fastercsv'

class Topic < ActiveRecord::Base
  SURVEY_NONE = 0
  SURVEY_INTERNAL = 1
  SURVEY_EXTERNAL = 2

  has_many :sessions
  validates_presence_of :name, :description, :minutes
  validates_presence_of :survey_url, :if => Proc.new{ |topic| topic.survey_type == SURVEY_EXTERNAL }, :message => "must be specified to use an external survey."
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
  
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
  
  def average_instructor_rating
    survey_responses.inject(0.0) { |sum, rating| sum + rating.instructor_rating } / survey_responses.size
  end
  
  def average_rating
    survey_responses.inject(0.0) { |sum, rating| sum + rating.class_rating } / survey_responses.size
  end
end
