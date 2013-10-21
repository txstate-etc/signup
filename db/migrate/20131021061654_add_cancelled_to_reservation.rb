class AddCancelledToReservation < ActiveRecord::Migration
  def self.up
    add_column :reservations, :cancelled, :boolean, :default => false
  end

  def self.down
    remove_column :reservations, :cancelled
  end
end
