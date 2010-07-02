require 'ri_cal'

class SessionsController < ApplicationController
  def show
    @session = Session.find( params[:id] )
    @page_title = @session.time.to_s + ": " + @session.topic.name
    @reservation = Reservation.find_by_user_id_and_session_id( current_user.id, @session.id )
  end
  
  def new
    topic = Topic.find( params[ :topic_id ] )
    if current_user.admin?
      @session = Session.new
      @session.topic = topic
      @page_name = "Create New Session"
    else
      redirect_to topic
    end
  end
  
  def create
    if current_user.admin?
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
    if current_user.admin? or session.instructor == current_user
      session.cancelled = true
      session.save
      # TODO: Add logic to notify attendees that session was cancelled.
      flash[ :notice ] = "Session cancelled."
    end
    redirect_to session.topic
  end
  
  def download
    calendar = RiCal.Calendar
    calendar.add_x_property 'X-WR-CALNAME', 'All Training Sessions'
    Session.find( :all ).each do |session|
      calendar.add_subcomponent( session.to_event )
    end
    send_data(calendar.export, :type => 'text/calendar')
  end

end
