class Reservation < ActiveRecord::Base
  belongs_to :user
  belongs_to :session, touch: true
  counter_culture :session, 
      :column_name => Proc.new {|model| model.cancelled? ? nil : 'reservations_count' },
      :column_names => {
          ["reservations.cancelled = ?", 'false'] => 'reservations_count'
      }
  has_one :survey_response
  has_paper_trail

  scope :active, -> { where cancelled: false }

  validates :user_id, presence: { message: 'not recognized.' }, 
    uniqueness: { scope: :session_id, message: 'has already registered for this session.' }
  validates :session_id, presence: true
  validate :session_not_cancelled, on: :create
  
  after_save :send_accommodation_notice

  def session_not_cancelled
    errors[:base] << 'You cannot register for this session, as it has been cancelled.' if session.cancelled
  end

  def send_accommodation_notice
    return if session.in_past?

    if (new_record? && special_accommodations.blank?) || special_accommodations_changed?
      ReservationMailer.accommodation_notice( self ).deliver_later
    end
  end

  ATTENDANCE_UNKNOWN = 0
  ATTENDANCE_MISSED = 1
  ATTENDANCE_ATTENDED = 2

  def to_param
    "#{id}-#{session.topic.name.parameterize}"
  end

  def confirmed?
    session.confirmed?(self)
  end
  
  def on_waiting_list?
    session.on_waiting_list?(self)
  end
  
  def attended?
    attended == Reservation::ATTENDANCE_ATTENDED
  end

  def missed?
    attended == Reservation::ATTENDANCE_MISSED
  end

  def need_survey?
    !missed? && session.topic.survey_type != Topic::SURVEY_NONE && survey_response.nil?
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
        ReservationMailer.promotion_notice( new_confirmed_reservation ).deliver_later
        if session.next_time.today?
          session.instructors.each do |instructor|
            ReservationMailer.promotion_notice_instructor( new_confirmed_reservation, instructor ).deliver_later
          end
        end
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
    ReservationMailer.remind( session, user ).deliver_later
  end

end
