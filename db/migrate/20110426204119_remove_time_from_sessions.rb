class RemoveTimeFromSessions < ActiveRecord::Migration
  def self.up
    remove_column :sessions, :time
  end

  def self.down
    add_column :sessions, :time, :datetime
  end
end
