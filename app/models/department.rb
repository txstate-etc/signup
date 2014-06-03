class Department < ActiveRecord::Base
  has_many :topics, -> { where inactive: false }
end
