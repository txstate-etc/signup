json.array!(@survey_responses) do |survey_response|
  json.extract! survey_response, :id, :reservation_id, :class_rating, :instructor_rating, :applicability, :most_useful, :comments
  json.url survey_response_url(survey_response, format: :json)
end
