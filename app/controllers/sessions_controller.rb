class SessionsController < ApplicationController
  def show
    @session = Session.find( params[:id] )
    @page_title = @session.time.to_s + ": " + @session.topic.name
    @numberRegistered = @session.reservations.length
    if ( @session.seats )
      @seatsRemaining = @session.seats - @numberRegistered
    end
  end
  
  def new
    topic = Topic.find( params[ :topic_id ] )
    @session = Session.new
    @session.topic = topic
    @page_name = "Create New Session"
  end
  
  def create
    @session = Session.new( params[ :session ] )
    if @session.save
      flash[ :notice ] = "Session added."
      redirect_to @session.topic
    else
      @page_title = "Create New Session"
      render :action => 'new'
    end
  end

end
