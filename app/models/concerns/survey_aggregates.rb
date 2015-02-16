module SurveyAggregates
  extend ActiveSupport::Concern

  def average_instructor_rating
    survey_responses.inject(0.0) { |sum, rating| sum + rating.instructor_rating } / survey_responses.length
  end
  
  def average_rating
    survey_responses.inject(0.0) { |sum, rating| sum + rating.class_rating } / survey_responses.length
  end

  def average_applicability_rating
    ratings = survey_responses.reject { |rating| rating.applicability.nil? }
    ratings.inject(0.0) { |sum, rating| sum + rating.applicability } / ratings.length
  end

end
