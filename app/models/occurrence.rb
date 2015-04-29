class Occurrence < ActiveRecord::Base
  belongs_to :session, -> { where(cancelled: false) }, touch: true
  has_paper_trail

  default_scope { order :time }
  scope :upcoming, -> { where('time > ?', Time.now) }
  scope :in_past, -> { where('time < ?', Time.now) }

  validates :time, presence: true, uniqueness: { scope: :session_id }
  
  def self.in_range(first, last)
    Occurrence.joins(:session).where(time: first.to_time..last.to_time)
  end

  def self.in_month(month)
    self.in_range(month.beginning_of_month, month.end_of_month.end_of_day).includes(session: :topic)
  end
end
