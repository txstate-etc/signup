class Permission < ActiveRecord::Base
  belongs_to :department
  belongs_to :user
 
  validate :valid_user
  
  def valid_user
    self.errors.add(:user_id, " #{@invalid_user} not found") if @invalid_user
  end
  
  def name_and_login
    user.name_and_login if user
  end

  def name_and_login=(name)
    self.user = User.find_by_name_and_login(name)
    @invalid_user = (self.user.blank? ? "\"#{name}\"" : nil) 
  end

end
