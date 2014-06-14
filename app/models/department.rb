class Department < ActiveRecord::Base
  has_many :topics, -> { where inactive: false }
  scope :active, -> { where inactive: false }
  scope :by_name, -> { order :name }
end
