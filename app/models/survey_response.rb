class SurveyResponse < ActiveRecord::Base
  belongs_to :reservation
  validates_presence_of :class_rating, :instructor_rating
  validates_uniqueness_of :reservation_id, :message => "A survey has already been submitted for this reservation."
  
  def validate
    if self.reservation.session.time > Time.now
      errors.add_to_base "You can't provide feedback on a session that hasn't yet occurred" 
    elsif self.reservation.session.last_time > Time.now
      errors.add_to_base "You can't provide feedback on a session until the last meeting has occurred"
    end
  end
end
