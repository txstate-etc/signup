class ReservationsController < ApplicationController
  before_filter :authenticate, :except => :show
  before_action :set_reservation, only: [:show, :edit, :update, :destroy, :certificate, :send_reminder]

  # GET /reservations
  # GET /reservations.json
  def index
    admin_is_viewing_someone_else = params[ :user_login ] && current_user.admin?
    login = admin_is_viewing_someone_else ? params[ :user_login ] : current_user
    @user = User.find_or_lookup_by_login( login ) rescue nil
    if @user.nil?
      flash[:alert] = "Could not find user with Login ID #{params[ :user_login ]}" if admin_is_viewing_someone_else
      redirect_to request.referrer || root_url
      return
    end

    if admin_is_viewing_someone_else
      @page_title = "Reservations for #{@user.name}"
    else
      @page_title = "Your Reservations"
    end

    reservations = @user.reservations.includes(:survey_response, :user, session: [:occurrences, :topic])
    current_reservations = reservations.find_all{ |reservation| !reservation.session.in_past? }.sort {|a,b| a.session.next_time <=> b.session.next_time}
    @past_reservations = reservations.find_all{ |reservation| reservation.session.in_past? && reservation.attended != Reservation::ATTENDANCE_MISSED }
    @confirmed_reservations, @waiting_list_signups = current_reservations.partition { |r| r.confirmed? }

  end

  def show
    respond_to do |format|
      format.html { redirect_to reservations_path }
      format.ics do
        send_data @reservation.session.to_cal, 
          :type => 'text/calendar', 
          :disposition => 'inline; filename=training.ics', :filename=>'training.ics'
      end
    end
  end

  # GET /reservations/1/edit
  def edit
  end

  # POST /reservations
  # POST /reservations.json
  def create
    session = Session.find( params[ :session_id ] )
    admin_is_enrolling_someone_else = params[ :user_login ] && session && authorized?(session)
    login = admin_is_enrolling_someone_else ? params[ :user_login ] : current_user
    user = User.find_or_lookup_by_login( login ) rescue nil
    if user.nil?
      flash[:alert] = "Could not find user with Login ID #{params[ :user_login ]}" if admin_is_enrolling_someone_else
      redirect_to request.referrer || root_url
      return
    end

    @reservation = Reservation.find_by_user_id_and_session_id(user.id, params[ :session_id ])
    unless @reservation
      @reservation = Reservation.new(reservation_params)
      @reservation.session = session
      @reservation.user = user
    end

    if admin_is_enrolling_someone_else
      if @reservation.user.nil?
        flash[:alert] = "Could not find user with Login ID #{params[ :user_login ]}"
        redirect_to sessions_reservations_path(@reservation.session)
        return
      end
    elsif !@reservation.session.in_registration_period?
      flash[:alert] = "Registration is closed for this session."
      redirect_to @reservation.session 
      return
    end
    
    success = if @reservation.cancelled? && !@reservation.new_record?
      @reservation.uncancel! 
    else
      @reservation.save
    end
    
    @reservation.reload
    if success && @reservation.confirmed?
      ReservationMailer.confirm( @reservation ).deliver_later
 
      if @reservation.session.next_time.today?
        @reservation.session.instructors.each do |instructor|
          ReservationMailer.confirm_instructor( @reservation, instructor ).deliver_later
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
        flash[:alert] = "Unable to make reservation for " + params[ :user_login ] + ". " + errors
      end
      redirect_to sessions_reservations_path(@reservation.session) 
    else
      if success
        if @reservation.confirmed?
          flash[ :notice ] = "Your reservation has been confirmed."
        else
          flash[ :notice ] = "You have been added to the waiting list."
        end
      else
        errors = @reservation.errors.full_messages.join(" ")
        flash[:alert] = "Unable to make reservation. " + errors
      end
      redirect_to @reservation.session 
    end
  end

  # PATCH/PUT /reservations/1
  # PATCH/PUT /reservations/1.json
  def update
    respond_to do |format|
      if @reservation.update(reservation_params)
        format.html { redirect_to @reservation.session, notice: 'Reservation was successfully updated.' }
        format.json { render :show, status: :ok, location: @reservation }
      else
        format.html { render :edit }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reservations/1
  # DELETE /reservations/1.json
  def destroy
    superuser =  authorized? @reservation
    
    if @reservation.user != current_user && !superuser
      flash[:alert] = "Reservations can only be cancelled by their owner, an admin, or an instructor."
    elsif @reservation.session.started? && !superuser
      flash[:alert] = "Reservations cannot be cancelled once the session has begun."      
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
      redirect_to survey_results_session_path( @reservation.session )
    else
      redirect_to reservations_path
    end
  end

  def certificate
    superuser =  authorized? @reservation

    if @reservation.user != current_user && !superuser
      flash[ :alert ] = "Certificates can only be downloaded by their owner, an admin, or an instructor."
      if request.referrer.present?
        redirect_to request.referrer
      else
        redirect_to root_url
      end
      return
    end

    respond_to do |format|
      format.pdf { send_data CompletionCertificate.new.to_pdf(@reservation), :disposition => 'inline', :type => 'application/pdf' }
    end

    send_analytics('dt' => "Download Certificate - #{@reservation.session.topic.name}")
  end

  # send an email reminder to the student
  def send_reminder
    superuser =  authorized? @reservation
    
    if @reservation.user != current_user && !superuser
      flash[ :alert ] = "Reminders can only be sent by their owner, an admin, or an instructor."
    elsif @reservation.session.in_past? && !superuser
      flash[ :alert ] = "Reminders cannot be sent once the session has ended."      
    else
      @reservation.send_reminder
      flash[ :notice ] = "A reminder has been sent to #{@reservation.user.name}."
    end
    
    if @reservation.user == current_user
      redirect_to reservations_path
    elsif superuser
      redirect_to sessions_reservations_path( @reservation.session )
    else
      redirect_to root_url
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reservation_params
      params.key?(:reservation) ? 
        params.require(:reservation).permit(:special_accommodations) : {}
    end
end
