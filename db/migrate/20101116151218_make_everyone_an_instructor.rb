class MakeEveryoneAnInstructor < ActiveRecord::Migration
  def self.up
    remove_column :users, :instructor
    
    add_index :users, :name
    add_index :users, :login
  end

  def self.down
    create_column :users, :instructor, :boolean, :default => false, :null => false
    
    remove_index :users, :name
    remove_index :users, :login
  end
end
