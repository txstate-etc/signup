class TopicsController < ApplicationController
  before_action :set_topic, only: [:show, :edit, :delete, :update, :destroy, :history]
  layout 'topic_collection', only: [:index, :by_department, :by_site, :alpha, :grid]

  def grid
    @cur_month = begin 
      Date.new(params[:year].to_i, params[:month].to_i) 
    rescue 
      Date.today.beginning_of_month 
    end
  end

  # GET /topics/1
  # GET /topics/1.json
  def show
    @page_title = @topic.name
  end

  # This doesn't actually do the delete action (destroy does that)
  # It just display a confirmation/warning page here with a link to the destroy action
  def delete
    @page_title = @topic.name
  end

  # GET /topics/new
  def new
    @topic = Topic.new
  end

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
      format.html { redirect_to topics_url, notice: 'Topic was successfully destroyed.' }
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
    @all_depts = current_user.admin? && session[:departments] == 'all'

    # Editors: show topics for their departments only. 
    # Admins: show topics for their departments by default. Show all depts based on filter
    # Instructors: show departments for topics that they are instructors of plus any in
    @topics = Hash.new { |h,k| h[k] = SortedSet.new }
    if current_user.admin? && (@all_depts || !current_user.editor?)
      _topics = @upcoming ? Topic.upcoming : Topic.active
      _topics.each { |t| @topics[t.department] << t }
      Department.active.each { |d| @topics[d] ||= [] }
    else
      if current_user.editor?
        _topics = @upcoming ? current_user.upcoming_topics : current_user.topics
        _topics.each { |t| @topics[t.department] << t }
        current_user.departments.each { |d| @topics[d] ||= [] }
      end
      
      if current_user.instructor?
        # Add topics for which the current user is the instructor
        current_user.sessions.each do |session|
          @topics[session.topic.department] ||= []
          @topics[session.topic.department] << session.topic if !@upcoming || session.in_future?
        end
      end
    end

    render layout: 'application'
  end

  def history
    if authorized?(@topic) || current_user.instructor?(@topic)
      @page_title = "Topic History: " + @topic.name
    else
      redirect_to topics_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_topic
      #FIXME: make sure to create a 404 page
      @topic = Topic.find(params[:id])
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
end
