class AuthSessionNonNullFields < ActiveRecord::Migration
  def change
    change_column_null :auth_sessions, :credentials, false
    change_column_null :auth_sessions, :user_id, false
  end
end
