class CreateDepartments < ActiveRecord::Migration
  def self.up
    add_column :topics, :department_id, :integer
    
    create_table :departments do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    remove_column :topics, :department_id
    drop_table :departments
  end
end
