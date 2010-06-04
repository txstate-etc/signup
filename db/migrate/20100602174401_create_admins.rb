class CreateAdmins < ActiveRecord::Migration
  def self.up
    create_table :admins do |t|
      t.string :login, :null => false
      t.string :name, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :admins
  end
end
