class Department < ActiveRecord::Base
  has_many :topics
  
  default_scope :order => "name"
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
  
end
