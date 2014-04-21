class Site < ActiveRecord::Base
  has_many :sessions
  has_paper_trail
  
  def <=>(other)
    self.name <=> other.name
  end
  
  def default?
    if defined?(DEFAULT_SITE)
       id == DEFAULT_SITE
    end
  end

end
