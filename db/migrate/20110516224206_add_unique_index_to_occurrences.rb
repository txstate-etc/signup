class AddUniqueIndexToOccurrences < ActiveRecord::Migration
  INDEX_NAME = 'unique_occurrence_times_in_session'
  def self.up
    add_index( :occurrences, [ :session_id, :time ], :unique => true, :name => INDEX_NAME )
  end

  def self.down
    remove_index( :occurrences, INDEX_NAME )
  end
end
