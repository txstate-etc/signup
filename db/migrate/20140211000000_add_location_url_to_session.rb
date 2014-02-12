class AddLocationUrlToSession < ActiveRecord::Migration
  def self.up
    add_column :sessions, :location_url, :string
  end

  def self.down
    remove_column :sessions, :location_url
  end
end
