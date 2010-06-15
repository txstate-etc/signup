class Session < ActiveRecord::Base
  has_many :reservations
  belongs_to :topic
  belongs_to :instructor
  validates_presence_of :time, :instructor_id, :topic_id, :location
  
  default_scope :order => 'time'
  
  def space_is_available?
    return true if self.seats == nil
    return true if self.seats > Reservation.count( :conditions => ["session_id = ?", self.id ] )
    return false
  end
end
