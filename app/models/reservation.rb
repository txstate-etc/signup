class Reservation < ActiveRecord::Base
  belongs_to :session
  validates_presence_of :name, :login, :session_id
end
