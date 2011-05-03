class CreateOccurrences < ActiveRecord::Migration
  def self.up
    create_table :occurrences do |t|
      t.integer :session_id
      t.datetime :time

      t.timestamps
    end
    add_index :occurrences, :session_id
  end

  def self.down
    drop_table :occurrences
  end
end
