class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string :name, :null => false

      t.timestamps
    end
    add_index :sites, :name
    add_column :sessions, :site_id, :integer
  end

  def self.down
    remove_column :sessions, :site_id
    drop_table :sites
  end
end
