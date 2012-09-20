class AddInactiveFlagToTopic < ActiveRecord::Migration
  def self.up
    add_column :topics, :inactive, :boolean, :default => false
  end

  def self.down
    remove_column :topics, :inactive
  end
end
