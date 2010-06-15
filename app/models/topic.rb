class Topic < ActiveRecord::Base
  has_many :sessions
  validates_presence_of :name, :description, :minutes
  
  def upcoming_sessions
    sessions.find( :all, :conditions => [ "time > ? AND cancelled = false", Time.now ] )
  end
end
