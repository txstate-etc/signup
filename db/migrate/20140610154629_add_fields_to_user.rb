class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :login, :string, index: true, null: false
    add_column :users, :first_name, :string, index: true
    add_column :users, :last_name, :string, index: true, null: false
    add_column :users, :name_prefix, :string
    add_column :users, :title, :string
    add_column :users, :department, :string
    add_column :users, :admin, :boolean, default: false, null: false
    add_column :users, :manual, :boolean, default: false, null: false
    add_column :users, :inactive, :boolean, default: false, null: false
  end
end
