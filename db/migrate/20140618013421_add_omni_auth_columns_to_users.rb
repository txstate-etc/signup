class AddOmniAuthColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :credentials, :string
    add_index :users, :credentials, :unique => true
    add_index :users, [ :id, :credentials ], :unique => true
  end
end
