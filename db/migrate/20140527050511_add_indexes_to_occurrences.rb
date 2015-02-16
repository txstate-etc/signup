class AddIndexesToOccurrences < ActiveRecord::Migration
  def change
    add_index :occurrences, :session_id
    add_index :occurrences, [ :session_id, :time ], :unique => true, :name => 'unique_occurrence_times_in_session' 
  end
end
