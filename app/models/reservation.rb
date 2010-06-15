class Reservation < ActiveRecord::Base
  belongs_to :session
  validates_presence_of :name, :login, :session_id
  validates_uniqueness_of :login, :scope => [ :session_id ], :message => "This user has already registered for this session."
  validate_on_create :session_not_cancelled, :space_available, :not_in_past
  
  def session_not_cancelled
    errors.add_to_base("You cannot register for this session, as it has been cancelled.") if session.cancelled
  end
  
  def space_available
    errors.add_to_base("This class is full.") unless session.space_is_available?
  end
  
  def not_in_past
    errors.add_to_base("You cannot register for this class, as it has already occurred.") if session.time < Time.now
  end
  
  def to_cal
    calendar = RiCal.Calendar
    event = RiCal.Event 
    event.summary = session.topic.name
    event.description = session.topic.description
    event.dtstart = session.time
    event.dtend = session.time + session.topic.minutes * 60
    event.location = session.location
    calendar.add_subcomponent( event )
    return calendar.export
  end
    
end
