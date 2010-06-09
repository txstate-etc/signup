class SessionsController < ApplicationController
  def show
    @session = Session.find( params[:id] )
    @page_title = @session.time.to_s + ": " + @session.topic.name
    @numberRegistered = @session.reservations.length
    if ( @session.seats )
      @seatsRemaining = @session.seats - @numberRegistered
    end
    @current_user_registered = Reservation.find_by_login_and_session_id( current_user, @session.id ) != nil
  end
  
  def new
    topic = Topic.find( params[ :topic_id ] )
    if user_is_admin?
      @session = Session.new
      @session.topic = topic
      @page_name = "Create New Session"
    else
      redirect_to topic
    end
  end
  
  def create
    if user_is_admin?
      @session = Session.new( params[ :session ] )
      if @session.save
        flash[ :notice ] = "Session added."
        redirect_to @session.topic
      else
        @page_title = "Create New Session"
        render :action => 'new'
      end
    else
      redirect_to @session.topic
    end
  end
  
  def destroy
    session = Session.find( params[ :id ] )
    if user_is_admin? or user_is_instructor?( session )
      session.cancelled = true
      session.save
      # TODO: Add logic to notify attendees that session was cancelled.
      flash[ :notice ] = "Session cancelled."
    end
    redirect_to session.topic
  end

end
