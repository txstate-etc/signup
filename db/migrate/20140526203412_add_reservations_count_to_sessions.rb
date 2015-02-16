class AddReservationsCountToSessions < ActiveRecord::Migration

  def self.up

    add_column :sessions, :reservations_count, :integer, :null => false, :default => 0
    Reservation.counter_culture_fix_counts
    
  end

  def self.down

    remove_column :sessions, :reservations_count

  end

end
