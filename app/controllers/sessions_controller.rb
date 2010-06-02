class SessionsController < ApplicationController
  def show
    @session = Session.find( params[:id] )
    @page_title = @session.time.to_s + ": " + @session.topic.name
    @numberRegistered = @session.reservations.length
    @seatsRemaining = @session.seats - @numberRegistered
  end

end
