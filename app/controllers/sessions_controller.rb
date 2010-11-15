require 'ri_cal'

class SessionsController < ApplicationController
  before_filter :authenticate, :except => [ :download, :show ]
  
  def show
    @session = Session.find( params[:id] )
    @page_title = @session.time.to_s + ": " + @session.topic.name
    @title_image = 'date.png'
    @reservation = Reservation.find_by_user_id_and_session_id( current_user.id, @session.id ) if current_user
  end
  
  def new
    topic = Topic.find( params[ :topic_id ] )
    if current_user && current_user.admin?
      @session = Session.new
      @session.topic = topic
      @page_name = "Create New Session"
    else
      redirect_to topic
    end
  end
  
  def create
    if current_user && current_user.admin?
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
  
  def update
    @session = Session.find( params[ :id ] )
    if current_user && current_user.admin? || current_user == @session.instructor
      @session.update_attributes( params[ :session ] )
      flash[ :notice ] = "The Session's data has been updated."
      render :show
    else
      redirect_to @session.topic
    end
  end
  
  def destroy
    session = Session.find( params[ :id ] )
    if (current_user && current_user.admin? ) or session.instructor == current_user
      session.cancel!
    else
    end
    flash[ :notice ] = "The session has been cancelled and the attendees notified."
    redirect_to session.topic
  end
  
  def download
    calendar = RiCal.Calendar
    calendar.add_x_property 'X-WR-CALNAME', 'All Training Sessions'
    Session.find_all_by_cancelled( false ).each do |session|
      calendar.add_subcomponent( session.to_event )
    end
    send_data(calendar.export, :type => 'text/calendar')
  end

end
