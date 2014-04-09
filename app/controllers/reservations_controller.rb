class ReservationsController < ApplicationController
  before_filter :authenticate, :except => :download
  
  def create
    unless current_user
      redirect_to root_url
      return
    end

    user = if params[ :user_login ]
      User.find_by_login( params[ :user_login ] )
    else
      current_user
    end

    @reservation = Reservation.find_by_user_id_and_session_id(user.id, params[ :session_id ])
    unless @reservation
      @reservation = Reservation.new( params[ :reservation ] )
      @reservation.session = Session.find( params[ :session_id ] )
      @reservation.user = user
    end

    admin_is_enrolling_someone_else = params[ :user_login ] && authorized?(@reservation)
    if admin_is_enrolling_someone_else
      if @reservation.user.nil?
        flash[ :error ] = "Could not find user with Login ID #{params[ :user_login ]}"
        redirect_to attendance_path(@reservation.session)
        return
      end
    elsif !@reservation.session.in_registration_period?
      flash[ :error ] = "Registration is closed for this session."
      redirect_to @reservation.session 
      return
    end
    
    success = if @reservation.cancelled? && !@reservation.new_record?
      @reservation.uncancel! 
    else
      @reservation.save
    end
    
    if success && @reservation.confirmed?
      ReservationMailer.delay.deliver_confirm( @reservation ) 
 
      if @reservation.session.next_time.today?
        @reservation.session.instructors.each do |instructor|
          ReservationMailer.delay.deliver_confirm_instructor( @reservation, instructor )
        end
      end
    end

    if admin_is_enrolling_someone_else
      if success
        if @reservation.confirmed?
          flash[ :notice ] = "The reservation for #{@reservation.user.name} has been confirmed."
        else
          flash[ :notice ] = "#{@reservation.user.name} has been added to the waiting list."
        end
      else
        errors = @reservation.errors.full_messages.join(" ")
        flash[ :error ] = "Unable to make reservation for " + params[ :user_login ] + ". " + errors
      end
      redirect_to attendance_path(@reservation.session) 
    else
      if success
        if @reservation.confirmed?
          flash[ :notice ] = "Your reservation has been confirmed."
        else
          flash[ :notice ] = "You have been added to the waiting list."
        end
      else
        errors = @reservation.errors.full_messages.join(" ")
        flash[ :error ] = "Unable to make reservation. " + errors
      end
      redirect_to @reservation.session 
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
      @user = User.find_by_login( params[ :user_login ] )
      @page_title = "Reservations for #{@user.name}"
    else
      @user = current_user
      @page_title = "Your Reservations"
    end
    
    reservations = Reservation.active.find( :all, :conditions => ["user_id = ? AND sessions.cancelled = false", @user.id ], :include => [ :session ] )
    current_reservations = reservations.find_all{ |reservation| !reservation.session.in_past? }.sort {|a,b| a.session.next_time <=> b.session.next_time}
    @past_reservations = reservations.find_all{ |reservation| reservation.session.in_past? && reservation.attended != Reservation::ATTENDANCE_MISSED }
    @confirmed_reservations = current_reservations.find_all{ |reservation| reservation.confirmed? }
    @waiting_list_signups = current_reservations.find_all{ |reservation| reservation.on_waiting_list? }
  end
  
  def destroy
    @reservation = Reservation.find( params[ :id ] )
    superuser =  authorized? @reservation
    
    if @reservation.user != current_user && !superuser
      flash[ :error ] = "Reservations can only be cancelled by their owner, an admin, or an instructor."
    elsif @reservation.session.started? && !superuser
      flash[ :error ] = "Reservations cannot be cancelled once the session has begun."      
    else
      @reservation.cancel!
      if @reservation.user == current_user
        flash[ :notice ] = "Your reservation has been cancelled."
      else
        flash[ :notice ] = "The reservation for #{@reservation.user.name} has been cancelled."
      end
    end
    
    if request.referrer.present?
      redirect_to request.referrer
    elsif superuser
      redirect_to attendance_path( @reservation.session )
    else
      redirect_to reservations_path
    end
  end
  
  # send an email reminder to the student
  def send_reminder
    @reservation = Reservation.find( params[ :id ] )
    superuser =  authorized? @reservation
    
    if @reservation.user != current_user && !superuser
      flash[ :error ] = "Reminders can only be sent by their owner, an admin, or an instructor."
    elsif @reservation.session.in_past? && !superuser
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
  def send_followup
    @reservation = Reservation.find( params[ :id ] )
    superuser =  authorized? @reservation
    
    if @reservation.user != current_user && !superuser
      flash[ :error ] = "Survey reminders can only be sent by their owner, an admin, or an instructor."
    else
      @reservation.send_followup
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
  
  def certificate
    @reservation = Reservation.find( params[ :id ] )
    superuser =  authorized? @reservation

    if @reservation.user != current_user && !superuser
      flash[ :error ] = "Certificates can only be downloaded by their owner, an admin, or an instructor."
      if request.referrer.present?
        redirect_to request.referrer
      else
        redirect_to root_url
      end
    end

    respond_to do |format|
      format.pdf { send_data CompletionCertificate.new.to_pdf(@reservation), :disposition => 'inline', :type => 'application/pdf' }
    end
  end
end
