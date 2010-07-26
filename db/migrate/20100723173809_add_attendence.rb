class AddAttendence < ActiveRecord::Migration
  def self.up
    add_column :reservations, :attended, :integer, :default => 0
  end

  def self.down
    remove_column :reservations, :attended
  end
end
