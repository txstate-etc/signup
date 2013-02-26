class Site < ActiveRecord::Base

  def <=>(other)
    self.name <=> other.name
  end
  
  def default?
    if defined?(DEFAULT_SITE)
       id == DEFAULT_SITE
    end
  end

end
