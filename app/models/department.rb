class Department < ActiveRecord::Base
  has_many :topics, -> { where inactive: false }
  has_many :permissions
  has_many :users, :through => :permissions
  accepts_nested_attributes_for :permissions, :reject_if => lambda { |p| p['name_and_login'].blank? }, :allow_destroy => true
  scope :active, -> { where inactive: false }
  scope :by_name, -> { order :name }

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def upcoming
    topics.upcoming
  end

end
