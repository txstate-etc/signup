class UsersController < ApplicationController
  def index
    return if params[ :search ].blank?
    conditions = []
    params[ :search ].split(/\s+/).each do |word|
      conditions << "(first_name LIKE '%#{word}%' OR last_name LIKE '%#{word}%' OR login LIKE '%#{word}%')"
    end
    @users = User.all(:conditions => conditions.join(" AND "))
  end

end
