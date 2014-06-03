class TopicsController < ApplicationController
  before_action :set_topic, only: [:show, :edit, :delete, :update, :destroy]
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
