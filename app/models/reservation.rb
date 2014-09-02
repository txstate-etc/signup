class Reservation < ActiveRecord::Base
  belongs_to :user
  belongs_to :session
  counter_culture :session, 
      :column_name => Proc.new {|model| model.cancelled? ? nil : 'reservations_count' },
      :column_names => {
          ["reservations.cancelled = ?", 'false'] => 'reservations_count'
      }
  has_one :survey_response
  scope :active, -> { where cancelled: false }

  ATTENDANCE_UNKNOWN = 0
  ATTENDANCE_MISSED = 1
  ATTENDANCE_ATTENDED = 2

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

    # if success
    #   # Send promotion notice only if THIS reservation (the one we just cancelled) was confirmed
    #   session.reload
    #   if was_confirmed && !session.space_is_available? && !session.in_past?
    #     new_confirmed_reservation = session.confirmed_reservations.last
    #     ReservationMailer.delay.deliver_promotion_notice( new_confirmed_reservation )
    #     if session.next_time.today?
    #       session.instructors.each do |instructor|
    #         ReservationMailer.delay.deliver_promotion_notice_instructor( new_confirmed_reservation, instructor )
    #       end
    #     end
    #   end
    # end
    
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
end
