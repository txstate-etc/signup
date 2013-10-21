class Reservation < ActiveRecord::Base
  
  ATTENDANCE_UNKNOWN = 0
  ATTENDANCE_MISSED = 1
  ATTENDANCE_ATTENDED = 2
  
  belongs_to :session
  belongs_to :user
  validates_presence_of :user_id, :message => "not recognized"
  validates_presence_of :session_id
  validates_uniqueness_of :user_id, :scope => [ :session_id ], :message => "has already registered for this session."
  validate_on_create :session_not_cancelled
  has_one :survey_response
  named_scope :active, :conditions => { :cancelled => false }
  
  # The default order must be created_at. This is how we determine who gets promoted to
  # the waiting list when someone cancels.
  default_scope :order => "reservations.created_at"
  
  def session_not_cancelled
    errors.add_to_base("You cannot register for this session, as it has been cancelled.") if session.cancelled
  end
  
  def after_create
    ReservationMailer.delay.deliver_accommodation_notice( self ) if !special_accommodations.blank? && !session.in_past?
  end

  def after_update
    ReservationMailer.delay.deliver_accommodation_notice( self ) if special_accommodations_changed? && !session.in_past?
  end
  
  def confirmed?
    session.confirmed?(self)
  end
  
  def on_waiting_list?
    session.on_waiting_list?(self)
  end
  
  def cancel!
    was_confirmed = confirmed?

    self.cancelled = true
    success = self.save

    if success
      # Send promotion notice only if THIS reservation (the one we just cancelled) was confirmed
      session.reload
      if was_confirmed && !session.space_is_available? && !session.in_past?
        new_confirmed_reservation = session.confirmed_reservations.last
        ReservationMailer.delay.deliver_promotion_notice( new_confirmed_reservation )
      end
    end
    
    success
  end

  def uncancel!
    # TL;DR: Update the created_at when uncancelling a reservation!!!!

    # NB: Uncancelling a reservation should move the person to the end of the list, 
    # so he doesn't bump another person into the waiting list. So, we will have 
    # to change the created_at timestamp in the reservation record to the current 
    # time. Otherwise, he will go back in the same order that he was in originally.
    self.cancelled = false
    self.created_at = Time.now
    self.save
  end

  def send_reminder
    ReservationMailer.delay.deliver_remind( session, user )
  end
  
  def send_survey
    ReservationMailer.delay.deliver_survey_mail( self )
  end
  
end
