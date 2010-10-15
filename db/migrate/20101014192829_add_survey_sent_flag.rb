class AddSurveySentFlag < ActiveRecord::Migration
  def self.up
    add_column :sessions, :survey_sent, :boolean, :default => false
  end

  def self.down
    remove_column :sessions, :survey_sent
  end
end
