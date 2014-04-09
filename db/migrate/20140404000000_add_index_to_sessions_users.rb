class AddIndexToSessionsUsers < ActiveRecord::Migration
  def self.up
    add_index :sessions_users, :session_id
    add_index :sessions_users, :user_id
  end
  
  def self.down
    remove_index :sessions_users, :session_id
    remove_index :sessions_users, :user_id
  end
end
