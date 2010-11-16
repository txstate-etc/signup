class UsersController < ApplicationController
  def index
    @users = User.find( :all, :conditions => ['name like ? OR login like ?', "%#{ params[ :search ] }%", "%#{ params[ :search ] }%"])
  end

end
