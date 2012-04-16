require 'ri_cal'

class TopicsController < ApplicationController
  before_filter :authenticate, :except => [ :download, :show, :index ]
  
  def index
    if current_user && current_user.admin? && session[:filter] != 'upcoming'
      @topics = Topic.all
    else
      @topics = Topic.upcoming
    end
    
    @page_title = "Available Topics"
  end

  def filter
    session[:filter] = case params[:filter] 
      when 'upcoming' then 'upcoming'
      else 'all'
    end
    redirect_to topics_path
  end
  
  def show    
    begin
      @topic = Topic.find( params[:id] )
    rescue ActiveRecord::RecordNotFound
      render(:file => 'shared/404.erb', :status => 404, :layout => true) unless @session
      return
    end

    respond_to do |wants|
      wants.html do
        @page_title = @topic.name
      end
      
      wants.csv do
        send_data @topic.to_csv,
          :type => 'text/csv; charset=iso-8859-1; header=present',
          :disposition => "attachment; filename=#{@topic.to_param}.csv"
      end
    end
  end
  
  def new
    if current_user && current_user.admin?
      @topic = Topic.new
      @page_title = "Create New Topic"
    else
      redirect_to topics_path
    end
  end

  def edit
    if current_user && current_user.admin?
      begin
        @topic = Topic.find( params[:id] )
      rescue ActiveRecord::RecordNotFound
        render(:file => 'shared/404.erb', :status => 404, :layout => true) unless @session
        return
      end
      @page_title = "Update Topic Details"
    else
      redirect_to topics_path
    end
  end
  
  def create
    if current_user && current_user.admin?
      @topic = Topic.new( params[ :topic ] )
      if @topic.save
        flash[ :notice ] = "Topic \"" + @topic.name + "\" added."
        redirect_to @topic
      else
        @page_title = "Create New Topic"
        render :action => 'new'
      end
    else
      redirect_to topics_path
    end
  end
  
  def update
    @topic = Topic.find( params[ :id ] )
    if current_user && current_user.admin?
      success = @topic.update_attributes( params[ :topic ] )
      @page_title = @topic.name
      if success
        flash[ :notice ] = "The topic's data has been updated."
        redirect_to @topic
      else
        flash.now[ :error ] = "There were problems updating this topic."
        render :action => 'show'
      end
    else
      redirect_to @topic
    end
  end
  
  
  def download
    topic = Topic.find( params[ :id ] )
    calendar = RiCal.Calendar
    calendar.add_x_property 'X-WR-CALNAME', topic.name
    topic.sessions.each do |session|
      session.to_event.each { |event| calendar.add_subcomponent( event ) } if !session.cancelled
    end
    send_data(calendar.export, :type => 'text/calendar')
  end

  def survey_results
    if current_user && current_user.admin?
      @topic = Topic.find( params[ :id ] )
      @page_title = @topic.name
    else
      redirect_to topics_path
    end
  end
  
end
