class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login, :null => false
      t.string :email, :null => false
      t.string :name, :null => false
      t.boolean :admin, :null => false, :default => false
      t.boolean :instructor, :null => false, :default => false

      t.timestamps
    end
    add_index :users, :login
  end

  def self.down
    drop_table :users
  end
end
