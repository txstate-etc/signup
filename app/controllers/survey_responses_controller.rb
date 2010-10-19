class SurveyResponsesController < ApplicationController
  before_filter :authenticate
  
  def new
    reservation = Reservation.find( params[ :reservation_id ] )
    if current_user == reservation.user
      @survey_response = SurveyResponse.new
      @survey_response.reservation = reservation
      @page_title = "Survey For \"" + reservation.session.topic.name + "\""
    else
      redirect_to topics_path
    end
  end

  def create
    @survey_response = SurveyResponse.new( params[ :survey_response ] )
    if current_user == @survey_response.reservation.user
      if @survey_response.save
        flash[ :notice ] = "Your survey results have been recorded. Thank you for your input!"
        redirect_to topics_path
      else
        @page_title = "Survey For \"" + @survey_response.reservation.session.topic.name + "\""
        render :action => 'new'
      end
    else
      redirect_to topics_path
    end
  end
  
  def index
  end
end
