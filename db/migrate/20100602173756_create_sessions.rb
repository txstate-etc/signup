class CreateSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.datetime :time, :null => false
      t.integer :instructor_id, :null => false
      t.integer :topic_id, :null => false
      t.string :location, :null => false
      t.boolean :cancelled, :null => false, :default => false
      t.integer :seats

      t.timestamps
    end
  end

  def self.down
    drop_table :sessions
  end
end
