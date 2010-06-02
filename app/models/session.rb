class Session < ActiveRecord::Base
  has_many :reservations
  belongs_to :topic
  belongs_to :instructor
end
