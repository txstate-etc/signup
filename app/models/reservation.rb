class Reservation < ActiveRecord::Base
  belongs_to :user
  belongs_to :session
  counter_culture :session, 
      :column_name => Proc.new {|model| model.cancelled? ? nil : 'reservations_count' },
      :column_names => {
          ["reservations.cancelled = ?", 'false'] => 'reservations_count'
      }
  has_one :survey_response

  ATTENDANCE_UNKNOWN = 0
  ATTENDANCE_MISSED = 1
  ATTENDANCE_ATTENDED = 2

end
