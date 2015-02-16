class CreateAuthSessions < ActiveRecord::Migration
  def change
    create_table :auth_sessions do |t|
      t.string :credentials
      t.references :user, index: true

      t.timestamps
    end
    add_index :auth_sessions, :credentials, unique: true

    remove_index :users, :column => [ :id, :credentials ]
    remove_column :users, :credentials, :string
  end
end
