class CreateOccurrences < ActiveRecord::Migration
  def change
    create_table :occurrences do |t|
      t.references :session, null: false
      t.datetime :time, null: false

      t.timestamps
    end
  end
end
