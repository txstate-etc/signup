class ReservationsController < ApplicationController
  before_filter :authenticate, :except => :download
  
  def new
    @session = Session.find( params[ :session_id ] )
    @reservation = Reservation.new
    @reservation.session = @session
    @page_title = "Make a Reservation"
  end
  
  def create
    @reservation = Reservation.new( params[ :reservation ] )
    @session = Session.find( params[ :session_id ] )
    @reservation.session = @session
    admin_is_enrolling_someone_else = params[ :user_login ] && authorized?(@reservation)
    if admin_is_enrolling_someone_else
      @reservation.user = User.find_by_login( params[ :user_login ] )
      if @reservation.user.nil?
        flash[ :error ] = "Could not find user with Login ID #{params[ :user_login ]}"
        redirect_to attendance_path(@reservation.session)
        return
      end
    else
      @reservation.user = current_user
    end
    
    success = @reservation.save
    ReservationMailer.delay.deliver_confirm( @reservation ) if success &&  @reservation.confirmed?
 
    if admin_is_enrolling_someone_else
      if success
        if @reservation.confirmed?
          flash[ :notice ] = "The reservation for #{@reservation.user.name} has been confirmed."
        else
          flash[ :notice ] = "#{@reservation.user.name} has been added to the waiting list."
        end
      else
        flash[ :error ] = "Unable to make reservation for " + params[ :user_login ]
      end
      redirect_to attendance_path(@reservation.session) 
    else
      if success
        if @reservation.confirmed?
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
  end
  
  def edit
    begin
      @reservation = Reservation.find( params[:id] )
    rescue ActiveRecord::RecordNotFound
      render(:file => 'shared/404.erb', :status => 404, :layout => true) unless @reservation
      return
    end

    superuser =  authorized? @reservation
    
    if @reservation.user == current_user || superuser
      @page_title = "Update Reservation Details"
    else
      redirect_to root_url
    end
  end
  
  def update
    @reservation = Reservation.find( params[:id] )
    if @reservation.user == current_user || authorized?(@reservation)
      success = @reservation.update_attributes( params[ :reservation ] )
      if success
        flash[ :notice ] = "The reservation's data has been updated."
        redirect_to @reservation.session
      else
        @page_title = "Update Reservation Details"
        flash.now[ :error ] = "There were problems updating this reservation."
        render :action => 'edit'
      end
    else
      redirect_to root_url
    end
  end
  
  def index
    admin_is_viewing_someone_else = params[ :user_login ] && current_user.admin?
    if admin_is_viewing_someone_else
      user = User.find_by_login( params[ :user_login ] )
      @page_title = "Reservations for #{user.name}"
    else
      user = current_user
      @page_title = "Your Reservations"
    end
    
    reservations = Reservation.find( :all, :conditions => ["user_id = ? AND sessions.cancelled = false", user.id ], :include => [ :session ] )
    current_reservations = reservations.find_all{ |reservation| reservation.session.last_time > Time.now }.sort {|a,b| a.session.next_time <=> b.session.next_time}
    @past_reservations = reservations.find_all{ |reservation| reservation.session.last_time <= Time.now && reservation.attended != Reservation::ATTENDANCE_MISSED }
    @confirmed_reservations = current_reservations.find_all{ |reservation| reservation.confirmed? }
    @waiting_list_signups = current_reservations.find_all{ |reservation| reservation.session.time > Time.now && !reservation.confirmed? }
  end
  
  def destroy
    @reservation = Reservation.find( params[ :id ] )
    superuser =  authorized? @reservation
    
    if @reservation.user != current_user && !superuser
      flash[ :error ] = "Reservations can only be cancelled by their owner, an admin, or an instructor." + current_user.to_s + " & " + @reservation.user.to_s
    elsif @reservation.session.time <= Time.now && !superuser
      flash[ :error ] = "Reservations cannot be cancelled once the session has begun."      
    else
      @reservation.destroy
      if @reservation.user == current_user
        flash[ :notice ] = "Your reservation has been cancelled."
      else
        flash[ :notice ] = "The reservation for #{@reservation.user.name} has been cancelled."
      end
    end
    
    if !superuser
      redirect_to reservations_path
    else
      redirect_to request.referrer
    end
  end
  
  # send an email reminder to the student
  def send_reminder
    @reservation = Reservation.find( params[ :id ] )
    superuser =  authorized? @reservation
    
    if @reservation.user != current_user && !superuser
      flash[ :error ] = "Reminders can only be sent by their owner, an admin, or an instructor." + current_user.to_s + " & " + @reservation.user.to_s
    elsif @reservation.session.last_time < Time.now && !superuser
      flash[ :error ] = "Reminders cannot be sent once the session has ended."      
    else
      @reservation.send_reminder
      flash[ :notice ] = "A reminder has been sent to #{@reservation.user.name}."
    end
    
    if @reservation.user == current_user
      redirect_to reservations_path
    else
      redirect_to attendance_path( @reservation.session )
    end
  end
  
  # send an email reminder to the student
  def send_survey
    @reservation = Reservation.find( params[ :id ] )
    superuser =  authorized? @reservation
    
    if @reservation.user != current_user && !superuser
      flash[ :error ] = "Survey reminders can only be sent by their owner, an admin, or an instructor." + current_user.to_s + " & " + @reservation.user.to_s
    else
      @reservation.send_survey
      flash[ :notice ] = "A survey reminder has been sent to #{@reservation.user.name}."
    end
    
    if @reservation.user == current_user
      redirect_to reservations_path
    else
      redirect_to attendance_path( @reservation.session )
    end
  end
  
  def download
    reservation = Reservation.find( params[ :id ] )
    send_data(reservation.session.to_cal, :type => 'text/calendar', :disposition => 'inline; filename=training.ics', :filename=>'training.ics')
  end
  
end
