require 'ri_cal'

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
    if current_user.admin?
      @topic = Topic.new
      @page_title = "Create New Topic"
    else
      redirect_to topics_path
    end
  end
  
  def create
    if current_user.admin?
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
  
  def download
    topic = Topic.find( params[ :id ] )
    calendar = RiCal.Calendar
    calendar.add_x_property 'X-WR-CALNAME', topic.name
    topic.sessions.each do |session|
      calendar.add_subcomponent( session.to_event ) if !session.cancelled
    end
    send_data(calendar.export, :type => 'text/calendar')
  end

end
