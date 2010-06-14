require 'ri_cal'

class ReservationsController < ApplicationController
  def new
    @session = Session.find( params[ :session_id ] )
    @reservation = Reservation.new
    @page_title = "Make a Reservation"
  end
  
  def create
    @reservation = Reservation.new
    @session = Session.find( params[ :session_id ])
    @reservation.session = @session
    @reservation.login = current_user
    @reservation.name = current_user_name
    if @reservation.save
      flash[ :notice ] = "Your reservation has been confirmed."
      redirect_to @reservation.session
    else
      @page_title = "Make a Reservation"
      render :action => 'new'
    end
  end
  
  def index
    @page_title = "Your Reservations"
    @reservations = Reservation.find( :all, :conditions => ["login = ? AND sessions.time > ?", current_user, Time.now ], :include => [ :session ] )
  end
  
  def destroy
    @reservation = Reservation.find( params[ :id ] )
    if @reservation.login == current_user
      @reservation.destroy
      flash[ :notice ] = "Your reservation has been cancelled."
    end
    redirect_to reservations_path
  end
  
  def download
    reservation = Reservation.find( params[ :id ] )
    
    calendar = RiCal.Calendar do
      event do
        summary reservation.session.topic.name
        description reservation.session.topic.description
        dtstart reservation.session.time
        dtend reservation.session.time + reservation.session.topic.minutes * 60
        location reservation.session.location
      end
    end
    
    send_data(calendar.export, :type => 'text/calendar', :disposition => 'inline; filename=training.ics', :filename=>'training.ics')
  end
  
end
