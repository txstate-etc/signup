class AddApplicabilityMostUsefulToSurveyResponses < ActiveRecord::Migration
  def self.up
    add_column :survey_responses, :applicability, :integer
    add_column :survey_responses, :most_useful, :text
  end

  def self.down
    remove_column :survey_responses, :most_useful
    remove_column :survey_responses, :applicability
  end
end
