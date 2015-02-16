require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  fixtures :sessions, :users

  test "Login Required for actions that modify records" do
    get :show, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :success
    
    get :download
    assert_response :success
    
    get :new, :topic_id => sessions( :tracs ).topic_id
    assert_response :redirect
    assert_redirected_to "/auth/cas?url=#{@request.url}"
    
    get :create, :topic_id => sessions( :tracs ).topic_id
    assert_response :redirect
    assert_redirected_to "/auth/cas?url=#{@request.url}"

    get :edit, :id => sessions( :tracs )
    assert_response :redirect
    assert_redirected_to "/auth/cas?url=#{@request.url}"

    delete :destroy, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :redirect    
    assert_redirected_to "/auth/cas?url=#{@request.url}"
    assert !sessions( :tracs ).cancelled
    
    post :update, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :redirect    
    assert_redirected_to "/auth/cas?url=#{@request.url}"
    assert_not_equal "The Session's data has been updated.", flash[:notice]

    # reset the response object or it will give a redirect loop error after five redirects
    setup_controller_request_and_response

    get :reservations, :id => sessions( :tracs )
    assert_response :redirect
    assert_redirected_to "/auth/cas?url=#{@request.url}"

    get :survey_results, :id => sessions( :tracs )
    assert_response :redirect
    assert_redirected_to "/auth/cas?url=#{@request.url}"

    get :email, :id => sessions( :tracs )
    assert_response :redirect
    assert_redirected_to "/auth/cas?url=#{@request.url}"
  end
  
  test "Admins can do anything" do
    login_as( users( :admin1 ) )
    get :show, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :success
    
    get :download
    assert_response :success
    
    get :new, :topic_id => sessions( :tracs ).topic_id
    assert_response :success
    
    get :edit, :id => sessions( :tracs )
    assert_response :success
    
    post :create, :topic_id => sessions( :tracs ).topic_id, :session => { :topic_id => sessions( :tracs ).topic_id }
    assert_response :success

    delete :destroy, :id => sessions( :tracs ).id
    assert_response :redirect    
    assert_redirected_to topic_path(sessions( :tracs ).topic)
    assert sessions( :tracs ).reload.cancelled

    patch :update, :id => sessions( :tracs ).id, :session => { :location => "New place"}
    assert_redirected_to session_path(sessions( :tracs ))
    assert_match /was successfully updated/, flash[:notice]

    get :reservations, :id => sessions( :tracs )
    assert_response :success

    get :survey_results, :id => sessions( :tracs )
    assert_response :success

    get :email, :id => sessions( :tracs )
    assert_response :redirect
    assert_redirected_to sessions_reservations_path(sessions( :tracs ))
  end
  
  test "Instructors can delete and update own sessions" do
    login_as( users( :instructor2 ) )
    get :show, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :success
    
    get :download
    assert_response :success
    
    get :new, :topic_id => sessions( :tracs ).topic_id
    assert_redirected_to topic_path(sessions( :tracs ).topic)
    assert_response :redirect
    
    get :edit, :id => sessions( :tracs )
    assert_response :success
    
    post :create, :topic_id => sessions( :tracs ).topic_id, :session => { :topic_id => sessions( :tracs ).topic_id }
    assert_redirected_to root_url
    assert_response :redirect

    delete :destroy, :id => sessions( :tracs ).id
    assert_response :redirect    
    assert_redirected_to topic_path(sessions( :tracs ).topic)
    assert sessions( :tracs ).reload.cancelled
    
    patch :update, :id => sessions( :tracs ).id, :session => { :location => "New place"}
    assert_redirected_to session_path(sessions( :tracs ))
    assert_match /was successfully updated/, flash[:notice]

    get :reservations, :id => sessions( :tracs )
    assert_response :success

    get :survey_results, :id => sessions( :tracs )
    assert_response :success

    get :email, :id => sessions( :tracs )
    assert_response :redirect
    assert_redirected_to sessions_reservations_path(sessions( :tracs ))
  end
  
  test "Instructors can NOT delete and update other sessions" do
    login_as( users( :instructor1 ) )
    get :show, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :success
    
    get :download
    assert_response :success
    
    get :new, :topic_id => sessions( :tracs ).topic_id
    assert_redirected_to topic_path(sessions( :tracs ).topic)
    assert_response :redirect
    
    get :edit, :id => sessions( :tracs )
    assert_response :redirect
    assert_redirected_to root_path
    
    post :create, :topic_id => sessions( :tracs ).topic_id, :session => { :topic_id => sessions( :tracs ).topic_id }
    assert_redirected_to root_path
    assert_response :redirect

    delete :destroy, :id => sessions( :tracs ).id
    assert_response :redirect    
    assert_redirected_to root_path
    assert !sessions( :tracs ).reload.cancelled
    
    patch :update, :id => sessions( :tracs ).id, :session => { :location => "New place"}
    assert_redirected_to root_path
    assert_no_match /was successfully updated/, flash[:notice]

    get :reservations, :id => sessions( :tracs )
    assert_response :redirect
    assert_redirected_to root_path

    get :survey_results, :id => sessions( :tracs )
    assert_response :redirect
    assert_redirected_to root_path

    get :email, :id => sessions( :tracs )
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "Editors can delete and update own sessions" do
    login_as( users( :editor1 ) )
    get :show, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :success
    
    get :download
    assert_response :success
    
    get :new, :topic_id => sessions( :tracs ).topic_id
    assert_response :success
    
    get :edit, :id => sessions( :tracs )
    assert_response :success
    
    post :create, :topic_id => sessions( :tracs ).topic_id, :session => { :topic_id => sessions( :tracs ).topic_id }
    assert_response :success

    delete :destroy, :id => sessions( :tracs ).id
    assert_response :redirect    
    assert_redirected_to topic_path(sessions( :tracs ).topic)
    assert sessions( :tracs ).reload.cancelled
    
    patch :update, :id => sessions( :tracs ).id, :session => { :location => "New place"}
    assert_redirected_to session_path(sessions( :tracs ))
    assert_match /was successfully updated/, flash[:notice]

    get :reservations, :id => sessions( :tracs )
    assert_response :success

    get :survey_results, :id => sessions( :tracs )
    assert_response :success

    get :email, :id => sessions( :tracs )
    assert_response :redirect
    assert_redirected_to sessions_reservations_path(sessions( :tracs ))
  end
  
  test "Editors can NOT delete and update other sessions" do
    login_as( users( :editor1 ) )
    get :show, :topic_id => sessions( :multi_time_topic ).topic_id, :id => sessions( :multi_time_topic ).id
    assert_response :success
    
    get :download
    assert_response :success
    
    get :new, :topic_id => sessions( :multi_time_topic ).topic_id
    assert_redirected_to topic_path(sessions( :multi_time_topic ).topic)
    assert_response :redirect
    
    get :edit, :id => sessions( :multi_time_topic )
    assert_response :redirect
    assert_redirected_to root_path
    
    post :create, :topic_id => sessions( :multi_time_topic ).topic_id, :session => { :topic_id => sessions( :multi_time_topic ).topic_id }
    assert_redirected_to root_url
    assert_response :redirect

    delete :destroy, :id => sessions( :multi_time_topic ).id
    assert_response :redirect    
    assert_redirected_to root_path
    assert !sessions( :multi_time_topic ).reload.cancelled
    
    patch :update, :id => sessions( :multi_time_topic ).id, :session => { :location => "New place"}
    assert_redirected_to root_path
    assert_no_match /was successfully updated/, flash[:notice]

    get :reservations, :id => sessions( :multi_time_topic )
    assert_response :redirect
    assert_redirected_to root_path

    get :survey_results, :id => sessions( :multi_time_topic )
    assert_response :redirect
    assert_redirected_to root_path

    get :email, :id => sessions( :multi_time_topic )
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "Regular users should be able to view, but not make changes" do
    login_as( users( :plainuser1 ) )
    get :show, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :success
    
    get :download
    assert_response :success

    get :new, :topic_id => sessions( :tracs ).topic_id
    assert_redirected_to topic_path(sessions( :tracs ).topic)
    assert_response :redirect
    
    get :edit, :id => sessions( :tracs )
    assert_response :redirect
    assert_redirected_to root_path
    
    post :create, :topic_id => sessions( :tracs ).topic_id, :session => { :topic_id => sessions( :tracs ).topic_id }
    assert_redirected_to root_url
    assert_response :redirect

    delete :destroy, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_response :redirect    
    assert_redirected_to root_path
    assert !sessions( :tracs ).cancelled
    
    patch :update, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_redirected_to root_path
    assert_response :redirect

    get :reservations, :id => sessions( :tracs )
    assert_response :redirect
    assert_redirected_to root_path

    get :survey_results, :id => sessions( :tracs )
    assert_response :redirect
    assert_redirected_to root_path

    get :email, :id => sessions( :tracs )
    assert_response :redirect
    assert_redirected_to root_path
  end
  
  test "Session page should show whether a user is registered" do
    login_as( users( :plainuser1 ) )
    get :show, :topic_id => sessions( :gato ).topic_id, :id => sessions( :gato ).id
    assert_match /You are registered for this session/, @response.body

    get :show, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs ).id
    assert_no_match /You are registered for this session/, @response.body
  end
  
  test "Should be able to download subscribable calendar without credentials" do
    get :download
    assert_response :success
    assert_equal @response.content_type, 'text/calendar'
  end
    
  test "Should display printable attendance sheet" do
    login_as( users( :instructor1 ) )
    get :reservations, {'id' => sessions( :gato_overbooked ), 'format' => 'pdf'}
    assert_response :success
    assert_equal 'application/pdf', @response.content_type
    assert_not_nil assigns(:session)    
  end
  
  test "Should be able to update attendance" do
    login_as( users( :admin1 ) )
    patch :update, :id => sessions( :gato ).id, :session => { :reservations_attributes => { 0 => {:id => reservations( :plainuser1 ).id, :attended => 1 } } }
    assert_equal assigns( :session ).errors.count, 0, "Sessions should have saved successfully. Error: " + assigns( :session ).errors.full_messages().to_s
  end
  
  
end
