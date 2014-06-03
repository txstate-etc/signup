class Occurrence < ActiveRecord::Base
  belongs_to :session, -> { where cancelled: false }
  default_scope { order :time }
  scope :upcoming, -> { where('time > ?', Time.now) }

  def self.in_range(first, last)
    Occurrence.joins(:session).where(time: first.to_time..last.to_time)
  end

  def self.in_month(month)
    self.in_range(month.beginning_of_month, month.end_of_month.end_of_day)
  end
end
