class CreateHttpSessions < ActiveRecord::Migration
  def self.up
    create_table :http_sessions do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end

    add_index :http_sessions, :session_id
    add_index :http_sessions, :updated_at
  end

  def self.down
    drop_table :http_sessions
  end
end
