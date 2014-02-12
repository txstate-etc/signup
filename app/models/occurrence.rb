class Occurrence < ActiveRecord::Base
  belongs_to :session
  default_scope :order => 'time'  
  validates_presence_of :time
  validates_uniqueness_of :time, :scope => :session_id
  has_paper_trail

  def self.in_range(first, last)
    Occurrence.find( :all, :joins => :session, :conditions => [ "occurrences.time >= ? AND occurrences.time <= ? AND sessions.cancelled = false", first.to_time, last.to_time ] )
  end

  def self.in_month(month)
    self.in_range(month.beginning_of_month, month.end_of_month.end_of_day)
  end
end
