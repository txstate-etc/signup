class TopicsController < ApplicationController
  def index
    @topics = Topic.find( :all, { :order => "name asc"} )
    @page_title = "Available Course Topics"
  end
  
  def show
    @topic = Topic.find( params[:id] )
    @page_title = @topic.name
  end
  
  def new
    @topic = Topic.new
    @page_title = "Create New Topic"
  end
  
  def create
    @topic = Topic.new( params[ :topic ] )
    @topic.save
    flash[ :notice ] = "Topic \"" + @topic.name + "\" added."
    redirect_to topics_path
  end

end
