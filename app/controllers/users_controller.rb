class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]
  before_filter :authenticate_user!

  def index
    @users = User.manual.active
    redirect_to root_url unless authorized? @users
  end

  def show
    redirect_to root_url and return unless authorized? #Not editing, just viewing. Any authorization level is OK.

    # Currently, the 'show' page is only useful for viewing 
    # sessions that an instructor has taught. Out of paranoiac 
    # privacy concerns, lets block viewing anyone else for now.
    redirect_to root_url and return unless @user.instructor?
    
    @page_title = @user.name

    @topics = Hash.new { |h,k| h[k] = Array.new }
    @user.sessions.each do |session|
      @topics[session.topic] << session
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    
    # use email for login if they didn't supply one 
    # (login is not currently supported for manually created users)
    @user.login ||= @user.email
    @user.manual = true

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /topics/1
  # PATCH/PUT /topics/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      #FIXME: make sure to create a 404 page
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(
        :name_prefix, 
        :first_name,
        :last_name,
        :email,
        :department, 
        :title
      )
    end
end
