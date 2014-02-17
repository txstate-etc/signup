class AddCertificateToTopic < ActiveRecord::Migration
  def self.up
    add_column :topics, :certificate, :boolean, :default => false
  end

  def self.down
    remove_column :topics, :certificate
  end
end
