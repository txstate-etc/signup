class AddUniqueIndexToReservations < ActiveRecord::Migration
  def change
    add_index :reservations, [ :session_id, :user_id ], :unique => true
  end
end
