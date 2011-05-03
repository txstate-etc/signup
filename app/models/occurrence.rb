class Occurrence < ActiveRecord::Base
  belongs_to :session
  default_scope :order => 'time'  
  validates_presence_of :time
end
