class TopicsController < ApplicationController
  def index
    @topics = Topic.find( :all, { :order => "name asc"} )
    @page_title = "Available Course Topics"
  end
  
  def show
    @topic = Topic.find( params[:id] )
    @page_title = @topic.name
  end

end
