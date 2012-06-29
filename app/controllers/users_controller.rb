class UsersController < ApplicationController
  def index
    return if params[ :search ].blank?
    conditions = []
    values = []
    params[ :search ].split(/\s+/).each do |word|
      conditions << "(first_name LIKE ? OR last_name LIKE ? OR login LIKE ?)"
      3.times { values << "%#{word}%" }
    end
    @users = User.all(:conditions => [conditions.join(" AND ")] + values)
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self, root_url)
  end
  
end
