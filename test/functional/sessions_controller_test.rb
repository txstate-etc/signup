require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  fixtures :sessions, :users

  test "Login Required for actions that modify records" do
    get :show, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :success
    
    get :new, :topic_id => sessions( :tracs ).topic_id
    assert_response :redirect
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
    
    get :create, :topic_id => sessions( :tracs ).topic_id
    assert_response :redirect
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)

    delete :destroy, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :redirect    
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
    assert !sessions( :tracs ).cancelled
    
    post :update, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :redirect    
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
    assert_not_equal "The Session's data has been updated.", flash[:notice]
  end
  
  test "Admins can do anything" do
    login_as( users( :admin1 ) )
    get :show, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :success
    
    get :new, :topic_id => sessions( :tracs ).topic_id
    assert_response :success
    
    get :create, :topic_id => sessions( :tracs ).topic_id, :session => { :topic_id => sessions( :tracs ).topic_id }
    assert_response :success

    delete :destroy, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :redirect    
    assert_redirected_to topic_path(sessions( :tracs ).topic)
    assert sessions( :tracs ).reload.cancelled

    post :update, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_redirected_to session_path(sessions( :tracs ))
    assert_equal "The Session's data has been updated.", flash[:notice]
  end
  
  test "Instructors can delete and update own sessions" do
    login_as( users( :instructor2 ) )
    get :show, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :success
    
    get :new, :topic_id => sessions( :tracs ).topic_id
    assert_redirected_to topic_path(sessions( :tracs ).topic)
    assert_response :redirect
    
    get :create, :topic_id => sessions( :tracs ).topic_id, :session => { :topic_id => sessions( :tracs ).topic_id }
    assert_redirected_to root_url
    assert_response :redirect

    delete :destroy, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :redirect    
    assert_redirected_to topic_path(sessions( :tracs ).topic)
    assert sessions( :tracs ).reload.cancelled
    
    post :update, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_redirected_to session_path(sessions( :tracs ))
    assert_equal "The Session's data has been updated.", flash[:notice]
  end
  
  test "Regular users should be able to view, but not make changes" do
    login_as( users( :plainuser1 ) )
    get :show, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :success
    
    get :new, :topic_id => sessions( :tracs ).topic_id
    assert_redirected_to topic_path(sessions( :tracs ).topic)
    assert_response :redirect
    
    get :create, :topic_id => sessions( :tracs ).topic_id, :session => { :topic_id => sessions( :tracs ).topic_id }
    assert_redirected_to root_url
    assert_response :redirect

    delete :destroy, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :redirect    
    assert_redirected_to topic_path(sessions( :tracs ).topic)
    assert !sessions( :tracs ).cancelled
    
    post :update, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_redirected_to session_path(sessions( :tracs ))
    assert_response :redirect
  end
  
  test "Session page should show whether a user is registered" do
    login_as( users( :plainuser1 ) )
    get :show, :topic_id => sessions( :gato ).topic_id, :id => sessions( :gato ).id
    assert_match /You are registered for this session/, @response.body

    login_as( users( :plainuser2 ) )
    get :show, :topic_id => sessions( :gato ).topic_id, :id => sessions( :gato ).id
    assert_no_match /You are registered for this session/, @response.body
  end
  
  test "Should be able to download subscribable calendar without credentials" do
    get :download
    assert_response :success
    assert_equal @response.content_type, 'text/calendar'
  end
    
  test "Should display printable attendance sheet" do
    login_as( users( :instructor1 ) )
    get :attendance, {'id' => sessions( :gato_overbooked ), 'format' => 'pdf'}
    assert_response :success
    assert_equal 'application/pdf', @response.content_type
    assert_not_nil assigns(:session)    
  end
  
  test "Should be able to update attendance" do
    login_as( users( :admin1 ) )
    post :update, :id => sessions( :gato ).id, :session => { :reservations_attributes => { 0 => {:id => reservations( :plainuser1 ).id, :attended => 1 } } }, :reservations_update => :true
    assert_equal assigns( :session ).errors.count, 0, "Sessions should have saved successfully. Error: " + assigns( :session ).errors.full_messages().to_s
  end
  
  
end
