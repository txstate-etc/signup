class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.boolean :inactive, default: false

      t.timestamps
    end
  end
end
