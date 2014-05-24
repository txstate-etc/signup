class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.references :topic, index: true, null: false
      t.boolean :cancelled, default: false, null: false
      t.string :location, null: false
      t.string :location_url
      t.references :site, index: true
      t.integer :seats
      t.datetime :reg_start
      t.datetime :reg_end
      t.boolean :survey_sent, default: false

      t.timestamps
    end

    create_join_table :users, :sessions do |t|
      t.index :user_id
      t.index :session_id
    end
  end
end
