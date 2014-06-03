class Site < ActiveRecord::Base
  has_many :sessions

  def <=>(other)
    self.name <=> other.name
  end
  
end
