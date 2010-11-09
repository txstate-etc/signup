class AddDepartmentToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :department, :string
  end

  def self.down
    remove_column :users, :department
  end
end
