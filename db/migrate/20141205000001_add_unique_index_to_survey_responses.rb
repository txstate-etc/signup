class AddUniqueIndexToSurveyResponses < ActiveRecord::Migration
  def change
    remove_index :survey_responses, name: 'index_survey_responses_on_reservation_id'
    add_index :survey_responses, :reservation_id, :unique => true
  end
end
