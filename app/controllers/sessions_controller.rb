class SessionsController < ApplicationController
  before_filter :authenticate, :except => [ :download, :show ]
  before_action :set_session, only: [
    :show, 
    :edit, 
    :update, 
    :destroy, 
    :reservations,
    :survey_results,
    :survey_comments,
    :email
  ]
  before_filter :ensure_authorized, except: [:download, :new, :create, :show]

  def show
    respond_to do |format|
      format.html
      format.csv
      if authorized?(@session) || (current_user && current_user.editor?(@session))
        format.csv do
          data = cache(['sessions/csv', @session.topic, @session]) do
            @session.to_csv
          end
          send_csv data, @session 
        end
      end
    end
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
    if authorized? @session.topic
      respond_to do |format|
        if @session.save
          format.html { redirect_to @session, notice: 'Session was successfully created.' }
          format.json { render :show, status: :created, location: @session }
        else
          @session.occurrences.build unless @session.occurrences.present?
          @session.instructors.build unless @session.instructors.present?
          @page_title = @session.topic.name
          format.html { render :new }
          format.json { render json: @session.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to root_path
    end
  end

  # PATCH/PUT /sessions/1
  # PATCH/PUT /sessions/1.json
  def update
    respond_to do |format|
      attributes = session_params
      if @session.update(attributes)
        format.html do
          # If we just updated attendance info, go back to session#reservations. Otherwise, go to session#show
          next_page = attributes.key?(:reservations_attributes) ? sessions_reservations_path(@session) : @session
          redirect_to(next_page, notice: 'Session was successfully updated.') 
        end
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
    @session.cancel!( params[:custom_message] )
    respond_to do |format|
      format.html { redirect_to @session.topic, notice: 'The session has been cancelled and the attendees notified.' }
      format.json { head :no_content }
    end
  end

  def download
    data = cache("#{sess_key}/#{date_slug}/#{sites_key}/sessions/download", expires_in: 1.day) do
      calendar = RiCal.Calendar
      calendar.add_x_property 'X-WR-CALNAME', 'All Upcoming Sessions'
      Session.upcoming.includes(:topic,:site).each do |session|
        session.to_event.each { |event| calendar.add_subcomponent( event ) }
      end
      calendar.export
    end
    send_data(data, :type => 'text/calendar')
  end

  def reservations
    respond_to do |format|
      format.html
      format.csv { send_csv @session.to_csv, @session.to_param }
      format.pdf { send_data AttendanceReport.new.to_pdf(@session), :disposition => 'inline', :type => 'application/pdf' }
    end
  end

  def email
    @session.email_all(params[:message_text])
    flash[ :notice ] = "Your email has been sent."
    redirect_to sessions_reservations_path(@session)
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_session
      @session = Session.find(params[:id])
      @page_title = @session.topic.name
    end

    def ensure_authorized
      redirect_to root_path unless authorized? @session
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
        end if p['session'] && p['session']['occurrences_attributes']
      end
    end
end
