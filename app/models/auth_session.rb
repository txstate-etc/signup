class AuthSession < ActiveRecord::Base
  belongs_to :user

  def self.authenticated_user(user_id, credentials)
    return nil unless user_id.present? && credentials.present?
    AuthSession.find_by_credentials_and_user_id(credentials, user_id).try(:user)
  end
end
