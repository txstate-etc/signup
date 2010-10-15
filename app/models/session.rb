require 'ri_cal'

class Session < ActiveRecord::Base
  has_many :reservations
  belongs_to :topic
  belongs_to :instructor, :class_name => "User"
  validates_presence_of :time, :instructor_id, :topic_id, :location
  validates_numericality_of :seats, :only_integer => true, :allow_nil => true
  accepts_nested_attributes_for :reservations
  
  default_scope :order => 'time'
  
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
    self.seats ? reservations[ 0, self.seats ] : reservations
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
    event.description = topic.description + "\n\nInstructor: " + instructor.name
    event.dtstart = time
    event.dtend = time + topic.minutes * 60
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
end
