class UsersController < ApplicationController
  def index
    return if params[ :search ].blank?
    conditions = []
    values = []
    params[ :search ].split(/\s+/).each do |word|
      conditions << "(first_name LIKE ? OR last_name LIKE ? OR login LIKE ?)"
      3.times { values << "%#{word}%" }
    end
    @users = User.all(:select => "name_prefix, first_name, last_name, login", :conditions => [conditions.join(" AND ")] + values)
  end

end
