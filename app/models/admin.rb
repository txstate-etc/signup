class Admin < ActiveRecord::Base
  validates_presence_of :name, :login
end
