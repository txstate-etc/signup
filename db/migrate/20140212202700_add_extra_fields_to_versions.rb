class AddExtraFieldsToVersions < ActiveRecord::Migration
  def self.up
    add_column :versions, :ip, :string
    add_column :versions, :user_agent, :string
  end

  def self.down
    remove_column :versions, :user_agent
    remove_column :versions, :ip
  end
end
