class Reservation < ActiveRecord::Base
  
  ATTENDANCE_UNKNOWN = 0
  ATTENDANCE_MISSED = 1
  ATTENDANCE_ATTENDED = 2
  
  belongs_to :session
  belongs_to :user
  validates_presence_of :user_id, :message => "not recognized"
  validates_presence_of :session_id
  validates_uniqueness_of :user_id, :scope => [ :session_id ], :message => "This user has already registered for this session."
  validate_on_create :session_not_cancelled
  has_one :survey_response
  
  # The default order must be created_at. This is how we determine who gets promoted to
  # the waiting list when someone cancels.
  default_scope :order => "reservations.created_at"
  
  def session_not_cancelled
    errors.add_to_base("You cannot register for this session, as it has been cancelled.") if session.cancelled
  end
  
  def after_create
    ReservationMailer.delay.deliver_accommodation_notice( self ) if !special_accommodations.blank?
  end

  def after_update
    ReservationMailer.delay.deliver_accommodation_notice( self ) if special_accommodations_changed?
  end
  
  def before_destroy
    @was_confirmed = confirmed?
    
    true # We have to return true or the destroy will be aborted
  end
  
  def after_destroy
    # Send promotion notice only if THIS reservation (the one we just deleted) was confirmed
    session.reload
    if @was_confirmed && !session.space_is_available?
      new_confirmed_reservation = session.confirmed_reservations.last
      ReservationMailer.delay.deliver_promotion_notice( new_confirmed_reservation )
    end
  end
  
  def confirmed?
    session.seats ? session.reservations.index( self ) < session.seats : true
  end
  
  def on_waiting_list?
    !confirmed?
  end
  
  def send_reminder
    ReservationMailer.delay.deliver_remind( session, user )
  end
  
  def send_survey
    ReservationMailer.delay.deliver_survey_mail( self )
  end
  
end
