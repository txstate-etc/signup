class AddMultipleInstructorToSession < ActiveRecord::Migration
  def self.up
    create_table :sessions_users, :id => false do |t|
      t.integer :session_id, :null => false
      t.integer :user_id, :null => false
    end
  end

  def self.down
    drop_table :sessions_users
  end
end
