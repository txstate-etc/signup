class Reservation < ActiveRecord::Base
  
  ATTENDANCE_UNKNOWN = 0
  ATTENDANCE_MISSED = 1
  ATTENDANCE_ATTENDED = 2
  
  belongs_to :session
  belongs_to :user
  validates_presence_of :user_id, :message => "not recognized"
  validates_presence_of :session_id
  validates_uniqueness_of :user_id, :scope => [ :session_id ], :message => "This user has already registered for this session."
  validate_on_create :session_not_cancelled, :not_in_past
  has_one :survey_response
  
  default_scope :order => "reservations.created_at"
  
  def session_not_cancelled
    errors.add_to_base("You cannot register for this session, as it has been cancelled.") if session.cancelled
  end
  
  def not_in_past
    errors.add_to_base("You cannot register for this class, as it has already occurred.") if session.time < Time.now
  end
  
  def after_create
    ReservationMailer.deliver_accommodation_notice( self ) if !special_accommodations.blank?
  end
  
  def after_destroy
    if !session.space_is_available?
      new_confirmed_reservation = session.confirmed_reservations.last
      ReservationMailer.deliver_promotion_notice( new_confirmed_reservation )
    end
  end
  
  def confirmed?
    session.seats ? session.reservations.index( self ) < session.seats : true
  end
  
  def on_waiting_list?
    !confirmed?
  end
  
end
