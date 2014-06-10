class NonUniqueIndexOnEmail < ActiveRecord::Migration
  def change
    remove_index :users, :name => 'index_users_on_email'
    add_index :users, :email, unique: false
  end
end
