class CreateReservations < ActiveRecord::Migration
  def self.up
    create_table :reservations do |t|
      t.string :name, :null => false
      t.string :login, :null => false
      t.integer :session_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :reservations
  end
end
