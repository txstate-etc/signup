class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.references :topic, index: true
      t.attachment :item

      t.timestamps
    end
  end
end
