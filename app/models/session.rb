require 'ri_cal'

class Session < ActiveRecord::Base
  has_many :reservations
  belongs_to :topic
  has_and_belongs_to_many :instructors, :class_name => "User", :uniq => true
  validates_presence_of :time, :topic_id, :location
  validate :at_least_one_instructor, :valid_instructor
  validates_numericality_of :seats, :only_integer => true, :allow_nil => true
  after_validation :reload_if_invalid
  accepts_nested_attributes_for :reservations
  default_scope :order => 'time'
  
  def instructor?( user )
    instructors.include? user
  end
  
  # virtual attribute to handle instructor selection
  # instructor_name is of the format "Name (login_id)", e.g. "Sean McMains (sm51)"
  # or just the login id, e.g. "sm51"
  def instructor_name
    instructors[0].name_and_login if instructors.present?
  end
  
  def instructor_name=( name )
    if name.present?
      elements = name.split(/[(|)]/)
      if elements.size > 1
        user = User.find_by_login( elements[1] )
      else
        user = User.find_by_login( elements[0] )
      end
      if user.present?
        self.instructors << user
      else
        @invalid_instructor = true
      end
    end      
  end
  
  def valid_instructor
    if @invalid_instructor
      self.errors.add(:instructor, 'must be a valid user')
    end  
  end
  
  def at_least_one_instructor
    if self.instructors.blank? && !@invalid_instructor
      self.errors.add(:instructors, 'must not be blank')
    end
  end
  
  def reload_if_invalid
    #bring back any instructors that were deleted
    self.reload unless (self.new_record? || self.errors.empty?)
  end
  
  def to_param
    "#{id}-#{topic.name.parameterize}"
  end
  
  def after_update
    send_update = time_changed? || location_changed?
    if send_update
      confirmed_reservations.each do |reservation|
        ReservationMailer.deliver_update_notice( reservation )
      end
    end
  end
  
  def cancel!
    self.cancelled = true
    self.save
    confirmed_reservations.each do |reservation|
      ReservationMailer.deliver_cancellation_notice( reservation )
    end
  end
  
  def space_is_available?
    return true if self.seats == nil
    return true if self.seats > Reservation.count( :conditions => ["session_id = ?", self.id ] )
    return false
  end
  
  def confirmed_reservations
    results = self.seats ? reservations[ 0, self.seats ] : reservations
    return results.sort { |a,b| a.user.name <=> b.user.name }
  end
  
  def seats_remaining
    seats - confirmed_reservations.size if seats
  end
  
  def waiting_list
    self.seats && confirmed_reservations.size == self.seats ? reservations[ self.seats, reservations.size - self.seats ] : []
  end
  
  def to_cal
    calendar = RiCal.Calendar
    event = self.to_event
    calendar.add_subcomponent( event )
    return calendar.export
  end
  
  def to_event
    event = RiCal.Event 
    event.summary = topic.name
    event.description = topic.description + "\n\nInstructor(s): " + instructors.collect{|i| i.name}.join(", ")
    event.dtstart = time
    event.dtend = time + topic.minutes * 60
    event.url = topic.url
    event.location = location
    return event
  end
  
  def self.send_reminders( start_time, end_time )
    session_list = Session.find( :all, :conditions => ['time >= ? AND time <= ? AND cancelled = 0', start_time, end_time ] )
    session_list.each do |session|
      session.confirmed_reservations.each do |reservation|
        ReservationMailer.deliver_remind( reservation )
      end
    end
  end
  
  def self.send_surveys
    session_list = Session.all( :joins => :topic, :conditions => ['time < ? AND survey_sent = ? AND survey_type != ? AND cancelled = ?', DateTime.now, false, Topic::SURVEY_NONE, false ], :readonly => false)
    session_list.each do |session|
      session.confirmed_reservations.each do |reservation|
        ReservationMailer.deliver_survey_mail( reservation )
      end
      session.survey_sent = true
      session.save
    end
  end
  
  def survey_responses
    Reservation.all( :joins => :survey_response, :include => :survey_response, :conditions => [ 'session_id = ?', self ] ).collect{|reservation| reservation.survey_response}
  end
  
  def average_instructor_rating
    survey_responses.inject(0.0) { |sum, rating| sum + rating.instructor_rating } / survey_responses.size
  end
  
  def average_rating
    survey_responses.inject(0.0) { |sum, rating| sum + rating.class_rating } / survey_responses.size
  end
end
