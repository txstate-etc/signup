require 'test_helper'

class AuthSessionTest < ActiveSupport::TestCase
  
  test "Should get user from ID and credentials" do
    auth_session = auth_sessions(:plainuser1)
    user = users(:plainuser1)
    assert_equal user, AuthSession.authenticated_user(user.id, auth_session.credentials)
  end

  test "Should NOT get user from id and BAD credentials" do
    user = users(:plainuser1)
    assert_equal nil, AuthSession.authenticated_user(user.id, 'fake-credentials')
  end
  
  test "Should create AuthSession with user and credentials" do
    user = users(:editor1)
    credentials = 'some-ticket-from-auth-provider'
    assert_equal nil, AuthSession.authenticated_user(user.id, credentials)
    assert_nothing_raised do
      AuthSession.create!(credentials: credentials, user_id: user.id)
    end
    assert_equal user, AuthSession.authenticated_user(user.id, credentials)
  end

  test "Should create multiple AuthSession with same user and different credentials" do
    user = users(:editor1)
    credentials1 = 'some-ticket-from-auth-provider'
    assert_equal nil, AuthSession.authenticated_user(user.id, credentials1)
    assert_nothing_raised do
      AuthSession.create!(credentials: credentials1, user_id: user.id)
    end
    assert_equal user, AuthSession.authenticated_user(user.id, credentials1)
    
    credentials2 = 'another-ticket-from-auth-provider'
    assert_equal nil, AuthSession.authenticated_user(user.id, credentials2)
    assert_nothing_raised do
      AuthSession.create!(credentials: credentials2, user_id: user.id)
    end
    assert_equal user, AuthSession.authenticated_user(user.id, credentials2)

    assert 2, AuthSession.where(user_id: user.id).count
    assert 1, AuthSession.where(credentials: credentials1).count
    assert 1, AuthSession.where(credentials: credentials2).count
  end

  test "Should NOT create multiple AuthSession with different user and same credentials" do
    user1 = users(:editor1)
    credentials = 'some-ticket-from-auth-provider'
    assert_equal nil, AuthSession.authenticated_user(user1.id, credentials)
    assert_nothing_raised do
      AuthSession.create!(credentials: credentials, user_id: user1.id)
    end
    assert_equal user1, AuthSession.authenticated_user(user1.id, credentials)
    
    user2 = users(:plainuser2)
    assert_equal nil, AuthSession.authenticated_user(user2.id, credentials)
    assert_raises ActiveRecord::RecordNotUnique do
      AuthSession.create!(credentials: credentials, user_id: user2.id)
    end
    assert_equal nil, AuthSession.authenticated_user(user2.id, credentials)

    assert 1, AuthSession.where(credentials: credentials).count
    assert 1, AuthSession.where(user_id: user1.id).count
    assert 0, AuthSession.where(user_id: user2.id).count
   
  end

  test "Should NOT create AuthSession with missing user or credentials" do
    user = users(:editor1)
    credentials = 'some-ticket-from-auth-provider'
    assert_equal nil, AuthSession.authenticated_user(user.id, credentials)
    
    assert_raises ActiveRecord::RecordInvalid do
      AuthSession.create!(credentials: credentials, user_id: nil)
    end
    assert_raises ActiveRecord::RecordInvalid do
      AuthSession.create!(credentials: nil, user_id: user.id)
    end
    assert_raises ActiveRecord::RecordInvalid do
      AuthSession.create!(credentials: credentials, user_id: '')
    end
    assert_raises ActiveRecord::RecordInvalid do
      AuthSession.create!(credentials: '', user_id: user.id)
    end
    assert_raises ActiveRecord::RecordInvalid do
      AuthSession.create!(credentials: credentials)
    end
    assert_raises ActiveRecord::RecordInvalid do
      AuthSession.create!(user_id: user.id)
    end
    
    assert 0, AuthSession.where(user_id: user.id).count
    assert 0, AuthSession.where(credentials: credentials).count
    
  end

end
