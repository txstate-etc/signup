require 'ri_cal'

class SessionsController < ApplicationController
  before_filter :authenticate, :except => [ :download, :show ]
  
  def show
    begin
      @session = Session.find( params[:id] )
    rescue ActiveRecord::RecordNotFound
      render (:file => 'shared/404.erb', :status => 404, :layout => true) unless @session
      return
    end
    
    @page_title = @session.topic.name
    @reservation = Reservation.find_by_user_id_and_session_id( current_user.id, @session.id ) if current_user
  end
  
  def new
    topic = Topic.find( params[ :topic_id ] )
    if current_user && current_user.admin?
      @session = Session.new
      @session.topic = topic
      @session.occurrences.build
      @session.instructors.build
      @page_title = "Create New Session"
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
        @session.occurrences.build
        @session.instructors.build
        @page_title = "Create New Session"
        render :action => 'new'
      end
    else
      redirect_to @session
    end
  end
  
  def update
    @session = Session.find( params[ :id ] )
    if current_user && current_user.admin? || @session.instructor?( current_user )
      if @session.update_attributes( params[ :session ] )
        flash[ :notice ] = "The Session's data has been updated."
      else        
        flash[ :error ] = "There were problems updating this session: " + @session.errors.full_messages().to_s
      end
      @page_title = @session.time.to_s + ": " + @session.topic.name
      redirect_to @session
    else
      redirect_to @session
    end
  end
  
  def destroy
    session = Session.find( params[ :id ] )
    if (current_user && current_user.admin? ) or @session.instructor?( current_user )
      session.cancel!( params[:custom_message] )
    else
    end
    flash[ :notice ] = "The session has been cancelled and the attendees notified."
    redirect_to session.topic
  end
  
  def download
    calendar = RiCal.Calendar
    calendar.add_x_property 'X-WR-CALNAME', 'All Training Sessions'
    Session.find_all_by_cancelled( false ).each do |session|
      session.to_event.each { |event| calendar.add_subcomponent( event ) }
    end
    send_data(calendar.export, :type => 'text/calendar')
  end

  def attendance
    @session = Session.find( params[ :id ] )
    if current_user && current_user.admin? || @session.instructor?( current_user )
      send_data AttendanceReport.new.to_pdf(@session), :disposition => 'inline', :type => 'application/pdf'
    else
      redirect_to @session
    end
  end
  
end
