class Department < ActiveRecord::Base
  has_many :topics
  has_many :permissions
  has_many :users, :through => :permissions
  accepts_nested_attributes_for :permissions, :reject_if => lambda { |p| p['name_and_login'].blank? }, :allow_destroy => true
  default_scope :order => "name"
  
  validates_presence_of :name
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
  
end
