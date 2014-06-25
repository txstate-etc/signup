class SessionsController < ApplicationController
  before_action :set_session, only: [
    :show, 
    :edit, 
    :update, 
    :destroy, 
    :reservations,
    :survey_results
  ]

  # GET /sessions
  # GET /sessions.json
  def index
    @sessions = Session.all
  end

  # GET /sessions/new
  def new
    topic = Topic.find( params[ :topic_id ] )
    if authorized? topic
      @session = Session.new
      @session.topic = topic
      @session.occurrences.build
      @session.instructors.build
      @page_title = @session.topic.name
    else
      redirect_to topic
    end  
  end

  # POST /sessions
  # POST /sessions.json
  def create
    @session = Session.new(session_params)

    respond_to do |format|
      if @session.save
        format.html { redirect_to @session, notice: 'Session was successfully created.' }
        format.json { render :show, status: :created, location: @session }
      else
        format.html { render :new }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sessions/1
  # PATCH/PUT /sessions/1.json
  def update
    respond_to do |format|
      if @session.update(session_params)
        format.html { redirect_to @session, notice: 'Session was successfully updated.' }
        format.json { render :show, status: :ok, location: @session }
      else
        format.html { render :edit }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sessions/1
  # DELETE /sessions/1.json
  def destroy
    @session.destroy
    respond_to do |format|
      format.html { redirect_to sessions_url, notice: 'Session was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_session
      @session = Session.find(params[:id])
      @page_title = @session.topic.name
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def session_params
      fix_occurrences(params)
      params.require(:session).permit(
        :topic_id, 
        :cancelled, 
        :location, 
        :location_url, 
        :site_id, 
        :seats,
        :reg_start, 
        :reg_end, 
        :survey_sent,
        occurrences_attributes: [:id, :time, :_destroy],
        reservations_attributes: [:id, :attended],
        instructors_attributes: [:id, :name_and_login, :_destroy]
        )
    end

    # Some ActiveRecord bug is making times look like they have changed 
    # when they really haven't, causing unnecessary db writes.
    # Parsing the time before passing it to update() seems to fix it.
    def fix_occurrences(params)
      params.tap do |p|
        p['session']['occurrences_attributes'].each do |_,o|
          o['time'] = Time.parse(o['time']) rescue ''
        end
      end
    end
end
