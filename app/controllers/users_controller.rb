class UsersController < ApplicationController
  before_filter :authenticate

  def search
    return if params[ :search ].blank?
    conditions = ["inactive = 0"]
    values = []
    params[ :search ].split(/\s+/).each do |word|
      conditions << "(first_name LIKE ? OR last_name LIKE ? OR login LIKE ?)"
      3.times { values << "%#{word}%" }
    end
    @users = User.all(:select => "name_prefix, first_name, last_name, login", :conditions => [conditions.join(" AND ")] + values)
  end

  def index
    @users = User.manual.active
    @page_title = "Manage Users"
  end
  
  def new
    @user = User.new
    if authorized? @user
      @page_title = "Create New User"
    else
      redirect_to root_url
    end
  end

  def edit
    begin
      @user = User.find( params[:id] )
    rescue ActiveRecord::RecordNotFound
      render(:file => 'shared/404.erb', :status => 404, :layout => true) unless @user
      return
    end

    if authorized? @user
      @page_title = "Update User Details"
    else
      redirect_to root_url
    end
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
          flash[ :notice ] = "User \"#{@user.name}\" added."
          redirect_to users_path
        else
          @page_title = "Create New User"
          render :action => 'new'
        end
      end
      
      format.js # render the view
    end
  end

  def update
    @user = User.find( params[ :id ] )
    if authorized? @user
      success = @user.update_attributes( params[ :user ] )
      if success
        flash[ :notice ] = "The user \"#{@user.name}\" has been updated."
        redirect_to users_path
      else
        flash.now[ :error ] = "There were problems updating this user."
        @page_title = "Update User Details"
        render :action => 'edit'
      end
    else
      redirect_to root_url
    end
  end
  
  def destroy
    user = User.find( params[ :id ] )
    if authorized? user
      if user.deactivate!
        flash[ :notice ] = "The user \"#{user.name}\" has been deleted."
      else
        errors = user.errors.full_messages.join(" ")
        flash[ :error ] = "Unable to delete user \"#{user.name}\". " + errors
      end
      redirect_to users_path
    else
      redirect_to root_url
    end
  end

end
