class Instructor < ActiveRecord::Base
  has_many :sessions
  validates_presence_of :name, :login
end
