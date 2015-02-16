class CreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.string   :login, index: true, unique: true, null: false
      t.string   :email, index: true, null: false
      t.string   :first_name, index: true
      t.string   :last_name, index: true, null: false
      t.string   :name_prefix
      t.string   :title
      t.string   :department
      t.boolean  :admin, :boolean, default: false, null: false
      t.boolean  :manual, :boolean, default: false, null: false
      t.boolean  :inactive, :boolean, default: false, null: false

      t.timestamps
    end

    add_index :users, :login, unique: true
    add_index :users, :email
    add_index :users, :first_name
    add_index :users, :last_name
  end
end
