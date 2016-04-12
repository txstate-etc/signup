class UsersController < ApplicationController
  before_filter :authenticate
  before_action :set_user, only: [:new, :create, :show, :edit, :update, :destroy]
  before_filter :ensure_authorized, except: [:autocomplete_search, :show]

  def autocomplete_search
    users = User.directory_search(params[:term])
    users += User.active.manual.limit(10).search(params[:term])
    render json: users.map { |u| 
      name_and_login = User.name_and_login(u)
      { 
        :id => u[:login], 
        :label => name_and_login, 
        :value => name_and_login
      } 
    }.tap { |json|
      json << {
        :id => 'add-new', 
        :label => 'Add new...',
        :value => 'add-new'
      }
    }
  end

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

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params.merge(manual: true))

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: errors_with_dup, status: :unprocessable_entity 
        }
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
        format.json { render json: errors_with_dup, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.deactivate!
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      if action_name == 'new' || action_name == 'create'
        @user = User.new
      else
        @user = User.find_or_lookup_by_id(params[:id]) rescue nil
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(
        :login,
        :name_prefix, 
        :first_name,
        :last_name,
        :email,
        :department, 
        :title
      )
    end

    def ensure_authorized
      redirect_to root_path unless authorized? @user
    end

    def errors_with_dup
      { errors: @user.errors }.tap do |h|
        dup = @user.duplicate
        h[:duplicate] = dup.name_and_login if dup && !dup.inactive
      end
    end
end
