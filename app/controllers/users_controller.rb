class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = User.all
  end

  def show
    redirect_to root_url and return unless authorized? #Not editing, just viewing. Any authorization level is OK.

    @user = User.find(params[:id])

    # Currently, the 'show' page is only useful for viewing 
    # sessions that an instructor has taught. Out of paranoiac 
    # privacy concerns, lets block viewing anyone else for now.
    redirect_to root_url and return unless @user.instructor?
    
    @page_title = @user.name

    @topics = Hash.new { |h,k| h[k] = Array.new }
    @user.sessions.each do |session|
      @topics[session.topic] << session
    end
  end

end
