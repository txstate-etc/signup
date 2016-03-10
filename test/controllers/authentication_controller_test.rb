require 'test_helper'

class AuthSessionsControllerTest < ActionController::TestCase
  fixtures :users, :auth_sessions

  test "Should log users in with valid credentials" do
    credentials = 'some-ticket-from-auth-provider'
    user = users(:plainuser1)
    @request.env['omniauth.auth'] = { credentials: { ticket: credentials}, uid: user.login }
    get :create, provider: :cas, url: reservations_url
    assert_response :redirect
    assert_redirected_to reservations_url

    assert_equal user.id, session[:user]
    assert_equal credentials, session[:credentials]
    assert_equal user, AuthSession.authenticated_user(user.id, credentials)
  end

  test "Should NOT log users in without credentials" do
    user = users(:plainuser2)
    
    assert_raises NoMethodError, 'Trying to create a session with no credentials should rightly barf' do
      get :create, provider: :cas, url: reservations_url
    end

    assert_equal nil, session[:user]
    assert_equal nil, session[:credentials]
    assert_equal nil, AuthSession.find_by(user_id: user.id)
  end

  test "Should NOT log users in with unknown login" do
    user = 'notarealuser'
    credentials = 'some-ticket-from-auth-provider'
    @request.env['omniauth.auth'] = { credentials: { ticket: credentials}, uid: user }
    get :create, provider: :cas, url: reservations_url
    assert_response :redirect
    assert_redirected_to root_url
    assert_match /Oops! We could not log you in/, flash[:alert]

    assert_equal user, session[:auth_user]
    assert_equal nil, session[:user]
    assert_equal credentials, session[:credentials]
    assert_equal nil, AuthSession.find_by(credentials: credentials)
  end

  test "Logging out should destroy session" do
    auth_session = auth_sessions(:admin1)
    @request.session[:credentials] = auth_session.credentials
    @request.session[:user] = auth_session.user_id
    assert_equal auth_session, AuthSession.find_by(credentials: @request.session[:credentials])
    
    get :destroy
    assert_response :redirect
    assert_redirected_to "#{LOGOUT_URL}?url=#{CGI.escape(root_url)}"
   
    assert_equal nil, AuthSession.find_by(credentials: auth_session.credentials)
    assert_equal nil, session[:credentials]
    assert_equal nil, session[:user]

  end

  test "Single sign out request should destroy session" do
    auth_session = auth_sessions(:admin1)
    assert_equal auth_session, AuthSession.find_by(credentials: auth_session.credentials)
    
    # There is no route defined for single_sign_out, so we can't call it the normal way
    # get :single_sign_out, session_index: auth_session.credentials
    @request.headers['QUERY_STRING'] = "session_index=#{auth_session.credentials}"
    AuthSessionsController.action(:single_sign_out).call @request.env

    assert_response :success
    assert_equal 0, @response.body.length

    assert_equal nil, AuthSession.find_by(credentials: auth_session.credentials)
  end
end
