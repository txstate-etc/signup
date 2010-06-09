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
end
