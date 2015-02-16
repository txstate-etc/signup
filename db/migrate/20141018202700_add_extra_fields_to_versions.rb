class AddExtraFieldsToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :ip, :string
    add_column :versions, :user_agent, :string
  end
end
