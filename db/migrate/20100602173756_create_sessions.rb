class CreateSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.datetime :time
      t.integer :instructor_id
      t.integer :topic_id
      t.string :location
      t.boolean :cancelled

      t.timestamps
    end
  end

  def self.down
    drop_table :sessions
  end
end
