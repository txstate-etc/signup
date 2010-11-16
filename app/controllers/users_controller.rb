class UsersController < ApplicationController
  def index
    @users = User.name_like_all_or_login_like_all( params[ :search ].split(/\s+/) ) if !params[ :search ].blank?
  end

end
