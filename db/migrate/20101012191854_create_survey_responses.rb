class CreateSurveyResponses < ActiveRecord::Migration
  def self.up
    create_table :survey_responses do |t|
      t.integer :reservation_id
      t.integer :class_rating
      t.integer :instructor_rating
      t.text :comments

      t.timestamps
    end
    
    add_column :topics, :survey_type, :integer, :default => 1
    add_column :topics, :survey_url, :string
  end

  def self.down
    drop_table :survey_responses
    
    remove_column :topics, :survey_type
    remove_column :topics, :survey_url
  end
end
