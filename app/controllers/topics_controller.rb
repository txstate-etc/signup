class TopicsController < ApplicationController
  NO_AUTH_ACTIONS = [ :show, :download, :index, :alpha, :by_department, :by_site, :upcoming, :grid ]
  before_filter :authenticate, :except => NO_AUTH_ACTIONS
  before_action :set_topic, only: [:show, :new, :create, :edit, :download, :update, :delete, :destroy, :history, :survey_results, :survey_comments]
  before_action :set_title, only: [:show, :survey_results, :survey_comments]
  before_filter :ensure_authorized, except: NO_AUTH_ACTIONS + [:manage, :history]
  layout 'topic_collection', only: [:index, :by_department, :by_site, :alpha, :grid]

  def grid
    @cur_month = begin 
      Date.new(params[:year].to_i, params[:month].to_i) 
    rescue 
      Date.today.beginning_of_month 
    end
  end

  def show
    respond_to do |format|
      format.html
      format.atom
      format.ics do
        download
      end
      if authorized? @topic
        format.csv do
          data = cache(["#{date_slug}/topics/csv", @topic], expires_in: 1.day) do
            logger.debug { "generating csv for #{@topic.name}" }
            @topic.to_csv
          end
          send_csv data, @topic.to_param 
        end
      end
    end
  end

  def download
    data = cache(["#{date_slug}/topics/download", @topic], expires_in: 1.day) do
      calendar = RiCal.Calendar
      calendar.add_x_property 'X-WR-CALNAME', @topic.name
      @topic.upcoming_sessions.each do |session|
        session.to_event.each { |event| calendar.add_subcomponent( event ) }
      end
      calendar.export
    end
    send_data(data, :type => 'text/calendar')
  end
  
  # # GET /topics/new
  # def new
  #   @topic = Topic.new
  # end

  # POST /topics
  # POST /topics.json
  def create
    @topic = Topic.new(topic_params)

    respond_to do |format|
      if @topic.save
        format.html { redirect_to @topic, notice: 'Topic was successfully created.' }
        format.json { render :show, status: :created, location: @topic }
      else
        format.html { render :new }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /topics/1
  # PATCH/PUT /topics/1.json
  def update
    respond_to do |format|
      if @topic.update(topic_params)
        format.html { redirect_to @topic, notice: 'Topic was successfully updated.' }
        format.json { render :show, status: :ok, location: @topic }
      else
        flash.now[ :alert ] = "There were problems updating this topic."
        format.html { render :edit }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.json
  def destroy
    @topic.deactivate!
    respond_to do |format|
      format.html { redirect_to manage_topics_url, notice: "The topic \"#{@topic.name}\" has been deleted." }
      format.json { head :no_content }
    end
  end

  def manage
    redirect_to topics_path and return unless authorized?

    # sanitize the input to make sure we weren't passed anything bogus
    session[:topics] = case params['topics']
      when 'upcoming' then 'upcoming'
      else 'all'
    end if params.key?('topics')
    session[:departments] = case params['departments']
      when 'user' then 'user'
      else 'all'
    end if params.key?('departments')

    @upcoming = session[:topics] != 'all'
    @all_depts = current_user.admin? && (session[:departments] == 'all' || !current_user.editor?)

    # Editors: show topics for their departments only. 
    # Admins: show topics for their departments by default. Show all depts based on filter
    # Instructors: show departments for topics that they are instructors of
    @departments = Department.active.by_name
    list = @upcoming ? Topic.upcoming : Topic.active
    if !@all_depts
      @departments = @departments.where id: (
        current_user.department_ids + 
        current_user.sessions.map { |s| s.topic.department_id }
      ).uniq
      
      list = list.where(department: @departments)
    end

    @topics = Hash.new { |h,k| h[k] = SortedSet.new }
    list.each { |t| @topics[t.department_id] << t }

    render layout: 'application'
  end

  def history
    if authorized?(@topic) || current_user.instructor?(@topic)
      @page_title = "Topic History: " + @topic.name
    else
      redirect_to root_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_topic
      if action_name == 'new' || action_name == 'create'
        @topic = Topic.new
      else
        @topic = Topic.find(params[:id])
      end
    end

    def set_title
      @page_title = @topic.try(:name) || 'Topic Not Found'
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def topic_params
      params.require(:topic).permit(
        :name, 
        :description,
        :tag_list,
        :department_id,
        :minutes, 
        :url, 
        :survey_type, 
        :survey_url,
        :certificate,
        documents_attributes: [:id, :item, :_destroy]
      )
    end

    def ensure_authorized
      redirect_to root_path unless authorized? @topic
    end
end
