class Department < ActiveRecord::Base
  has_many :topics
end
