class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :name, :null => false
      t.text :description
      t.string :url
      t.integer :minutes

      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end
