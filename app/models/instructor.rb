class Instructor < ActiveRecord::Base
  has_many :sessions
end
