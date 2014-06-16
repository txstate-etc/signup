class Permission < ActiveRecord::Base
  belongs_to :department
  belongs_to :user


  def name_and_login
    user.name_and_login if user
  end
end
