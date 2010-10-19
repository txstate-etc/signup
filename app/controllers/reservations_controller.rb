class ReservationsController < ApplicationController
  before_filter :authenticate, :except => :download
  
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
      if @reservation.confirmed?
        ReservationMailer.deliver_confirm( @reservation )
        flash[ :notice ] = "Your reservation has been confirmed."
      else
        flash[ :notice ] = "You have been added to the waiting list."
      end
      redirect_to @reservation.session
    else
      @page_title = "Make a Reservation"
      render :action => 'new'
    end
  end
  
  def index
    @page_title = "Your Reservations"
    reservations = Reservation.find( :all, :conditions => ["user_id = ? AND sessions.time > ? and cancelled = false", current_user.id, Time.now ], :include => [ :session ] )
    @confirmed_reservations = reservations.find_all{ |reservation| reservation.confirmed? }
    @waiting_list_signups = reservations.find_all{ |reservation| !reservation.confirmed? }
  end
  
  def destroy
    @reservation = Reservation.find( params[ :id ] )
    if @reservation.user == current_user
      @reservation.destroy
      flash[ :notice ] = "Your reservation has been cancelled."
    else
      flash[ :error ] = "Reservations can only be cancelled by their owner." + current_user.to_s + " & " + @reservation.user.to_s
    end
    redirect_to reservations_path
  end
  
  def download
    reservation = Reservation.find( params[ :id ] )
    send_data(reservation.session.to_cal, :type => 'text/calendar', :disposition => 'inline; filename=training.ics', :filename=>'training.ics')
  end
  
end
