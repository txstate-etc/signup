class AddInactiveFlagToDepartment < ActiveRecord::Migration
  def self.up
    add_column :departments, :inactive, :boolean, :default => false
  end

  def self.down
    remove_column :departments, :inactive
  end
end
