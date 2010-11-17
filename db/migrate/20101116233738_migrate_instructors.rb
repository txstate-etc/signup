class MigrateInstructors < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      INSERT INTO sessions_users (session_id, user_id)
      SELECT sessions.id, instructor_id 
      FROM sessions
    SQL
  end

  def self.down
    execute <<-SQL
      UPDATE sessions SET instructor_id = (
        SELECT user_id 
        FROM sessions_users 
        WHERE session_id = sessions.id 
        LIMIT 1)
    SQL
  end
end
