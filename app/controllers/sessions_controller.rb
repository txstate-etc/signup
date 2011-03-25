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
        redirect_to @session
      else
        @page_title = "Create New Session"
        render :action => 'new'
      end
    else
      redirect_to @session
    end
  end
  
  def update
    # if no instructors are checked, then the browser won't send us an empty array like we expect
    params[:session][:instructor_ids] ||= [] unless params[:session].blank? || params[:reservations_update]
    @session = Session.find( params[ :id ] )
    if current_user && current_user.admin? || @session.instructor?( current_user )
      if @session.update_attributes( params[ :session ] )
        flash.now[ :notice ] = "The Session's data has been updated."
      else        
        flash.now[ :error ] = "There were problems updating this session: " + @session.errors.full_messages().to_s
      end
      @page_title = @session.time.to_s + ": " + @session.topic.name
      @title_image = 'date.png'
      render :show
    else
      redirect_to @session
    end
  end
  
  def destroy
    session = Session.find( params[ :id ] )
    if (current_user && current_user.admin? ) or @session.instructor?( current_user )
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

  def attendance
    @session = Session.find( params[ :id ] )
    if current_user && current_user.admin? || @session.instructor?( current_user )
      send_data @session.attendance_pdf, :disposition => 'inline', :type => 'application/pdf'
    else
      redirect_to @session
    end
  end
  
end
