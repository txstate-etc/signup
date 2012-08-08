class AddIndexToPermissions < ActiveRecord::Migration
  def self.up
    add_index :permissions, :department_id
    add_index :permissions, :user_id
  end

  def self.down
     remove_index :permissions, :user_id
     remove_index :permissions, :department_id
  end
end
