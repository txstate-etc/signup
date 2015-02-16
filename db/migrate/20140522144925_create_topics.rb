class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :name, null: false
      t.text :description
      t.string :url
      t.integer :minutes
      t.boolean :inactive, default: false
      t.boolean :certificate, default: false
      t.integer :survey_type, default: 1
      t.string :survey_url

      t.timestamps
    end
  end
end
