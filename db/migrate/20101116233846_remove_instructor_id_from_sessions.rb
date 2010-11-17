class RemoveInstructorIdFromSessions < ActiveRecord::Migration
  def self.up
    remove_column :sessions, :instructor_id
  end

  def self.down
    add_column :sessions, :instructor_id, :integer, :null => false
  end
end
