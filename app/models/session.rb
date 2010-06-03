class Session < ActiveRecord::Base
  has_many :reservations
  belongs_to :topic
  belongs_to :instructor
  validates_presence_of :time, :instructor_id, :topic_id, :location
end
