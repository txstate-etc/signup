class Site < ActiveRecord::Base
  has_many :sessions
  has_paper_trail

  def <=>(other)
    self.name <=> other.name
  end
  
end
