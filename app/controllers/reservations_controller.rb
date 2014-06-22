class ReservationsController < ApplicationController
  before_filter :authenticate #, :except => :download
  before_action :set_reservation, only: [:edit, :update, :destroy]

  # GET /reservations
  # GET /reservations.json
  def index
    admin_is_viewing_someone_else = params[ :user_login ] && current_user.admin?
    if admin_is_viewing_someone_else
      @user = User.find_by_login( params[ :user_login ] )
      @page_title = "Reservations for #{@user.name}"
    else
      @user = current_user
      @page_title = "Your Reservations"
    end

    reservations = @user.reservations
    current_reservations = reservations.find_all{ |reservation| !reservation.session.in_past? }.sort {|a,b| a.session.next_time <=> b.session.next_time}
    @past_reservations = reservations.find_all{ |reservation| reservation.session.in_past? && reservation.attended != Reservation::ATTENDANCE_MISSED }
    @confirmed_reservations, @waiting_list_signups = current_reservations.partition { |r| r.confirmed? }

  end

  # GET /reservations/1/edit
  def edit
  end

  # POST /reservations
  # POST /reservations.json
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
      @reservation = Reservation.new
      @reservation.session = Session.find( params[ :session_id ] )
      @reservation.user = user
    end

    admin_is_enrolling_someone_else = params[ :user_login ] && authorized?(@reservation)
    if admin_is_enrolling_someone_else
      if @reservation.user.nil?
        flash[ :error ] = "Could not find user with Login ID #{params[ :user_login ]}"
        redirect_to sessions_reservations_path(@reservation.session)
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
    
    # if success && @reservation.confirmed?
    #   ReservationMailer.delay.deliver_confirm( @reservation ) 
 
    #   if @reservation.session.next_time.today?
    #     @reservation.session.instructors.each do |instructor|
    #       ReservationMailer.delay.deliver_confirm_instructor( @reservation, instructor )
    #     end
    #   end
    # end

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
        flash[ :error ] = "Unable to make reservation. " + errors
      end
      redirect_to @reservation.session 
    end
  end

  # PATCH/PUT /reservations/1
  # PATCH/PUT /reservations/1.json
  def update
    respond_to do |format|
      if @reservation.update(reservation_params)
        format.html { redirect_to @reservation, notice: 'Reservation was successfully updated.' }
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
      redirect_to survey_results_session_path( @reservation.session )
    else
      redirect_to reservations_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reservation_params
      params.require(:reservation).permit(:special_accommodations)
    end
end
