class TopicsController < ApplicationController
  def index
    @topics = Topic.find( :all, { :order => "name asc"} )
    @page_title = "Available Topics"
  end
  
  def show
    @topic = Topic.find( params[:id] )
    @page_title = @topic.name
  end
  
  def new
    if user_is_admin?
      @topic = Topic.new
      @page_title = "Create New Topic"
    else
      redirect_to topics_path
    end
  end
  
  def create
    if user_is_admin?
      @topic = Topic.new( params[ :topic ] )
      if @topic.save
        flash[ :notice ] = "Topic \"" + @topic.name + "\" added."
        redirect_to topics_path
      else
        @page_title = "Create New Topic"
        render :action => 'new'
      end
    else
      redirect_to topics_path
    end
  end

end
