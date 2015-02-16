class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.references :user, index: true, null: false
      t.references :session, index: true, null: false
      t.boolean :cancelled, default: false
      t.integer :attended, default: 0
      t.text :special_accommodations

      t.timestamps
    end
  end
end
