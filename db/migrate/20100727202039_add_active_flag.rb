class AddActiveFlag < ActiveRecord::Migration
  def self.up
    add_column :users, :active, :boolean, :default => 1
    add_index :users, :active
  end

  def self.down
    remove_column :users, :active
  end
end
