class SurveyResponse < ActiveRecord::Base
  belongs_to :reservation
  has_paper_trail

  validates :class_rating, :instructor_rating, :applicability, presence: true
  validates :reservation, uniqueness: { message: 'A survey has already been submitted for this reservation.' }
  validate :validate_session_finished

  # Alias for comments column with a more descriptive name
  def general
    comments
  end

  def validate_session_finished
    if self.reservation.session.in_future?
      errors[:base] << "You can't provide feedback on a session that hasn't yet occurred" 
    elsif self.reservation.session.not_finished?
      errors[:base] << "You can't provide feedback on a session until the last meeting has occurred"
    end
  end
end
