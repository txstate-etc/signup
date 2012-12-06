class AddManualFlagToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :manual, :boolean, :default => false
  end

  def self.down
    remove_column :users, :manual
  end
end
