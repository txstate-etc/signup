class AddPrefixAndTitleToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :name_prefix, :string
    add_column :users, :title, :string
  end

  def self.down
    remove_column :users, :title
    remove_column :users, :name_prefix
  end
end
