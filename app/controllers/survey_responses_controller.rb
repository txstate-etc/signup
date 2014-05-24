class SurveyResponsesController < ApplicationController
  before_action :set_survey_response, only: [:show, :edit, :update, :destroy]

  # GET /survey_responses
  # GET /survey_responses.json
  def index
    @survey_responses = SurveyResponse.all
  end

  # GET /survey_responses/1
  # GET /survey_responses/1.json
  def show
  end

  # GET /survey_responses/new
  def new
    @survey_response = SurveyResponse.new
  end

  # GET /survey_responses/1/edit
  def edit
  end

  # POST /survey_responses
  # POST /survey_responses.json
  def create
    @survey_response = SurveyResponse.new(survey_response_params)

    respond_to do |format|
      if @survey_response.save
        format.html { redirect_to @survey_response, notice: 'Survey response was successfully created.' }
        format.json { render :show, status: :created, location: @survey_response }
      else
        format.html { render :new }
        format.json { render json: @survey_response.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /survey_responses/1
  # PATCH/PUT /survey_responses/1.json
  def update
    respond_to do |format|
      if @survey_response.update(survey_response_params)
        format.html { redirect_to @survey_response, notice: 'Survey response was successfully updated.' }
        format.json { render :show, status: :ok, location: @survey_response }
      else
        format.html { render :edit }
        format.json { render json: @survey_response.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /survey_responses/1
  # DELETE /survey_responses/1.json
  def destroy
    @survey_response.destroy
    respond_to do |format|
      format.html { redirect_to survey_responses_url, notice: 'Survey response was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_survey_response
      @survey_response = SurveyResponse.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def survey_response_params
      params.require(:survey_response).permit(:reservation_id, :class_rating, :instructor_rating, :applicability, :most_useful, :comments)
    end
end
