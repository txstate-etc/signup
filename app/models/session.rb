require 'ri_cal'

class Session < ActiveRecord::Base
  has_many :reservations
  belongs_to :topic
  belongs_to :instructor, :class_name => "User"
  validates_presence_of :time, :instructor_id, :topic_id, :location
  
  default_scope :order => 'time'
  
  def space_is_available?
    return true if self.seats == nil
    return true if self.seats > Reservation.count( :conditions => ["session_id = ?", self.id ] )
    return false
  end
  
  def confirmed_reservations
    self.seats ? reservations[ 0, self.seats ] : reservations
  end
  
  def waiting_list
    self.seats ? reservations[ self.seats, reservations.size - self.seats ] : nil
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
        ReservationMailer.deliver_remind( reservation, nil )
      end
    end
  end
end
