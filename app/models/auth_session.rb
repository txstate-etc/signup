class AuthSession < ActiveRecord::Base
  belongs_to :user

  validates :user, :credentials, presence: true

  def self.authenticated_user(user_id, credentials)
    return nil unless user_id.present? && credentials.present?
    User.joins(:auth_sessions).where(:'auth_sessions.credentials' => credentials).find_by(id: user_id)
  end
end
