class SurveyResponsesController < ApplicationController
  before_filter :authenticate
  
  def new
    reservation = Reservation.find( params[ :reservation_id ] )
    @survey_response = SurveyResponse.new
    @survey_response.reservation = reservation
    if authorized? @survey_response
      @page_title = reservation.session.topic.name
    else
      redirect_to topics_path
    end
  end

  def create
    @survey_response = SurveyResponse.new( params[ :survey_response ] )
    if authorized? @survey_response
      if @survey_response.save
        flash[ :notice ] = "Your survey results have been recorded. Thank you for your input!"
        redirect_to topics_path
      else
        @page_title = @survey_response.reservation.session.topic.name
        render :action => 'new'
      end
    else
      redirect_to topics_path
    end
  end
  
  def index
  end


  protected
  def authorized?(item=nil)
    # All users can create survey responses only for sessions they attended
    # Admins/Instructors cannot create survey responses if they themselves were not students in the session
    # No one can edit or destroy survey responses.
    if item.is_a? SurveyResponse
      return false unless item.new_record?
      reservation = item.reservation
      return reservation && current_user && reservation.user == current_user && reservation.confirmed?
    end

    super
  end

end
