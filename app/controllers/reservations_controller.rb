class ReservationsController < ApplicationController
  before_action :set_reservation, only: [:show, :edit, :update, :destroy]

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

  # GET /reservations/1
  # GET /reservations/1.json
  def show
  end

  # GET /reservations/new
  def new
    @reservation = Reservation.new
  end

  # GET /reservations/1/edit
  def edit
  end

  # POST /reservations
  # POST /reservations.json
  def create
    @reservation = Reservation.new(reservation_params)

    respond_to do |format|
      if @reservation.save
        format.html { redirect_to @reservation, notice: 'Reservation was successfully created.' }
        format.json { render :show, status: :created, location: @reservation }
      else
        format.html { render :new }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
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
    @reservation.destroy
    respond_to do |format|
      format.html { redirect_to reservations_url, notice: 'Reservation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reservation_params
      params.require(:reservation).permit(:user_id, :session_id, :cancelled, :attended, :special_accommodations)
    end
end
