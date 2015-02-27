class ChangeUserAgentInVersion < ActiveRecord::Migration
  def change
    change_column :versions, :user_agent, :text
  end
end
