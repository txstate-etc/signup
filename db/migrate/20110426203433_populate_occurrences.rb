class PopulateOccurrences < ActiveRecord::Migration
  def self.up
    # for each session, create new occurrence with id and time
    execute <<-SQL
      INSERT INTO occurrences (session_id, time)
      SELECT sessions.id, sessions.time 
      FROM sessions 
    SQL
  end

  def self.down
    execute <<-SQL
      UPDATE sessions SET time = (
        SELECT time 
        FROM occurrences 
        WHERE session_id = sessions.id 
        LIMIT 1)
    SQL
  end
end
