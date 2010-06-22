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
    @reservation.user = current_user
    if @reservation.save
      url = url_for( :host => request.host, :port => request.port, :controller => :reservations )
      ReservationMailer.deliver_confirm( @reservation, url )
      flash[ :notice ] = "Your reservation has been confirmed."
      redirect_to @reservation.session
    else
      @page_title = "Make a Reservation"
      render :action => 'new'
    end
  end
  
  def index
    @page_title = "Your Reservations"
    @reservations = Reservation.find( :all, :conditions => ["user_id = ? AND sessions.time > ?", current_user.id, Time.now ], :include => [ :session ] )
  end
  
  def destroy
    @reservation = Reservation.find( params[ :id ] )
    if @reservation.user == current_user
      @reservation.destroy
      flash[ :notice ] = "Your reservation has been cancelled."
    end
    redirect_to reservations_path
  end
  
  def download
    reservation = Reservation.find( params[ :id ] )
    send_data(reservation.session.to_cal, :type => 'text/calendar', :disposition => 'inline; filename=training.ics', :filename=>'training.ics')
  end
  
end
