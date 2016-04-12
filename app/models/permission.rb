class Permission < ActiveRecord::Base
  belongs_to :department
  belongs_to :user
  has_paper_trail

  validate :valid_user
  
  def valid_user
    errors[:user_id] << " #{@invalid_user} not found" if @invalid_user
  end
  def name_and_login
    user.name_and_login if user
  end

  def name_and_login=(name)
    self.user = User.find_or_lookup_by_name_and_login(name) rescue nil
    @invalid_user = (self.user.blank? ? "\"#{name}\"" : nil) 
  end

end
