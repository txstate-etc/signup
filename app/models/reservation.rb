class Reservation < ActiveRecord::Base
  belongs_to :user
  belongs_to :session
  counter_culture :session, 
      :column_name => Proc.new {|model| model.cancelled? ? nil : 'reservations_count' },
      :column_names => {
          ["reservations.cancelled = ?", 'false'] => 'reservations_count'
      }
end
