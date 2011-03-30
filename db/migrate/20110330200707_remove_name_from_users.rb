class RemoveNameFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :name
  end

  def self.down
    add_column :users, :name, :string
    add_index :users, :name
    execute <<-SQL
      UPDATE users SET name = CONCAT(first_name, ' ', last_name)
    SQL
  end
end
