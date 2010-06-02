class Topic < ActiveRecord::Base
  has_many :sessions
end
