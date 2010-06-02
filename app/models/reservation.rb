class Reservation < ActiveRecord::Base
  belongs_to :session
end
