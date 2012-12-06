class UsersController < ApplicationController
  before_filter :authenticate, :except => [ :index ]

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

  def create
    @user = User.new( params[ :user ] )
    redirect_to root_url and return unless authorized? @user

    # use email for login if they didn't supply one 
    # (login is not currently supported for manually created users)
    @user.login ||= @user.email
    @user.manual = true
    
    success = @user.save
    
    respond_to do |format|
      format.html do
        if success
          flash[ :notice ] = "User \"" + @user.name + "\" added."
          redirect_to @user
        else
          @page_title = "Create New User"
          render :action => 'new'
        end
      end
      
      format.js # render the view
    end

  end

end
