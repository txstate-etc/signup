class AddRegStartAndRegEndTimesToSession < ActiveRecord::Migration
  def self.up
    add_column :sessions, :reg_start, :datetime
    add_column :sessions, :reg_end, :datetime
  end

  def self.down
    remove_column :sessions, :reg_end
    remove_column :sessions, :reg_start
  end
end
