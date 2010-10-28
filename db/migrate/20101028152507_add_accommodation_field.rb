class AddAccommodationField < ActiveRecord::Migration
  def self.up
    add_column :reservations, :special_accommodations, :text
  end

  def self.down
    remove_column :reservations, :special_accommodations, :text
  end
end
