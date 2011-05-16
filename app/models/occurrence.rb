class Occurrence < ActiveRecord::Base
  belongs_to :session
  default_scope :order => 'time'  
  validates_presence_of :time
  validates_uniqueness_of :time, :scope => :session_id
end
