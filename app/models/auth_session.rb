class AuthSession < ActiveRecord::Base
  belongs_to :user

  def self.authenticated_user(user_id, credentials)
    return nil unless user_id.present? && credentials.present?
    User.where(id: user_id, :'auth_sessions.credentials' => credentials).joins(:auth_sessions).limit(1).first
  end
end
