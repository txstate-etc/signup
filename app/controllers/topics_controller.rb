require 'ri_cal'

class TopicsController < ApplicationController
  before_filter :authenticate, :except => [ :download, :show, :index ]
  
  def index
    @topics = Topic.upcoming
    @page_title = "Available Topics"
    
    render :layout => 'application'
  end

  def manage
    redirect_to topics_path and return unless authorized?

    @upcoming = session[:topics] != 'all'
    @all_depts = current_user.admin? && session[:departments] == 'all'

    # Non-admins: show topics for their departments only. 
    # Admins: show topics for their departments by default. Show all depts based on filter
    # Instructors: show departments for topics that they are instructors of plus any in
    @departments = current_user.departments
    @departments = Department.active if (current_user.admin? && (@all_depts || @departments.blank?))
    
    #FIXME: most of this work should be done by the database
    
    @topics = []
    if current_user.admin? || current_user.editor?
      # Show upcoming or all based on filter
      @topics = @upcoming ? Topic.upcoming : Topic.active
      @topics = @topics.select { |t| @departments.include? t.department }
    end
    
    if current_user.instructor?
      # Add topics for which the current user is the instructor
      @topics = (@topics + Topic.by_instructor(current_user, @upcoming)).flatten.uniq
      @departments = (@departments + @topics.map(&:department)).flatten.uniq
    end
    
    @page_title = "Manage Topics"
    render :layout => 'application'
  end

  def filter
    logger.debug "FILTER: #{params[:filter].join(',')}"
    # filter is an array of key value pairs, should be able to convert it to a hash
    filters = Hash[*params[:filter]]
    
    # sanitize the input to make sure we weren't passed anything bogus
    session[:topics] = case filters['topics']
      when 'upcoming' then 'upcoming'
      else 'all'
    end if filters.key?('topics')
    session[:departments] = case filters['departments']
      when 'user' then 'user'
      else 'all'
    end if filters.key?('departments')
    
    redirect_to manage_topics_path
  end
  
  def show    
    begin
      @topic = Topic.find( params[:id] )
    rescue ActiveRecord::RecordNotFound
      render(:file => 'shared/404.erb', :status => 404, :layout => true) unless @topic
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
    @topic = Topic.new
    if authorized? @topic
      @page_title = "Create New Topic"
    else
      redirect_to topics_path
    end
  end

  def edit
    begin
      @topic = Topic.find( params[:id] )
    rescue ActiveRecord::RecordNotFound
      render(:file => 'shared/404.erb', :status => 404, :layout => true) unless @topic
      return
    end

    if authorized? @topic
      @page_title = "Update Topic Details"
    else
      redirect_to @topic
    end
  end
  
  # This doesn't actually do the delete action (destroy does that)
  # It just display a confirmation/warning page here with a link to the destroy action
  def delete
    begin
      @topic = Topic.find( params[:id] )
    rescue ActiveRecord::RecordNotFound
      render(:file => 'shared/404.erb', :status => 404, :layout => true) unless @topic
      return
    end

    if authorized? @topic
      @page_title = @topic.name
    else
      redirect_to @topic
    end
  end
  
  def create
    @topic = Topic.new( params[ :topic ] )
    if authorized? @topic
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
    if authorized? @topic
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
  
  def destroy
    topic = Topic.find( params[ :id ] )
    if authorized? topic
      if topic.deactivate!
        flash[ :notice ] = "The topic \"#{topic.name}\" has been deleted."
        redirect_to manage_topics_path
        return
      else
        errors = topic.errors.full_messages.join(" ")
        flash[ :error ] = "Unable to delete topic \"#{topic.name}\". " + errors
      end
    end
    redirect_to topic
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
    @topic = Topic.find( params[ :id ] )
    if authorized? @topic
      @page_title = @topic.name
    else
      redirect_to topics_path
    end
  end
  
end
