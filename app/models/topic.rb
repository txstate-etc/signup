require 'fastercsv'

class Topic < ActiveRecord::Base
  SURVEY_NONE = 0
  SURVEY_INTERNAL = 1
  SURVEY_EXTERNAL = 2

  belongs_to :department
  has_many :sessions
  has_many :documents, :dependent => :destroy
  accepts_nested_attributes_for :documents, :allow_destroy => true, :reject_if => lambda { |t| t['item'].nil? }
  validates_presence_of :name, :description, :minutes, :department
  validates_associated :department
  validates_presence_of :survey_url, :if => Proc.new{ |topic| topic.survey_type == SURVEY_EXTERNAL }, :message => "must be specified to use an external survey."
  default_scope :order => 'name'
  
  def after_validation
    if !self.errors.empty?
      # delete any documents that were just uploaded, since they will have to be uploaded again
      documents.delete_if { |d| d.destroy if d.new_record? }
    end
    true
  end
  
  def self.upcoming
    Topic.find( :all, :conditions => [ "topics.id IN ( select topic_id from sessions, occurrences where sessions.id = occurrences.session_id AND occurrences.time > ? AND cancelled = false )", Time.now ] )
  end
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
  
  def upcoming_sessions
    sessions.find( :all, :conditions => [ "cancelled = false AND sessions.id NOT IN (SELECT session_id FROM occurrences WHERE occurrences.time <= ?)", Time.now ], :order => "occurrences.time", :include => :occurrences )
  end
  
  def past_sessions
    sessions.find( :all, :conditions => [ "occurrences.time < ? AND cancelled = false", Time.now ], :order => "occurrences.time", :include => :occurrences )
  end
  
  def to_csv
    FasterCSV.generate do |csv|
      csv << [ "Topic", "Session ID", "Session Time", "Session Cancelled", "Attendee Name", "Attendee Login", "Attendee Email", "Reservation Confirmed?", "Attended?" ]
      logger.info "FOO: STarting iterations"
      sessions.each do |session|
        logger.info "FOO: session - " + session.topic.name
        session.reservations.each do |reservation|
          logger.info "FOO: reservation - " + reservation.user.name
          attended = ""
          if reservation.attended == Reservation::ATTENDANCE_MISSED
            attended = "MISSED"
          elsif reservation.attended == Reservation::ATTENDANCE_ATTENDED
            attended = "ATTENDED"
          end
          csv << [ session.topic.name, session.id, session.time, session.cancelled, reservation.user.name, reservation.user.login, reservation.user.email, reservation.confirmed?, attended ]
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
