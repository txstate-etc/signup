class CreateSurveyResponses < ActiveRecord::Migration
  def change
    create_table :survey_responses do |t|
      t.references :reservation, index: true, null: false
      t.integer :class_rating
      t.integer :instructor_rating
      t.integer :applicability
      t.text :most_useful
      t.text :comments

      t.timestamps
    end
  end
end
