require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  fixtures :admins
  fixtures :instructors
  fixtures :sessions

  test "Login Required for All Actions" do
    get :show, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs )
    assert_response :redirect
    
    get :new, :topic_id => sessions( :tracs ).topic_id
    assert_response :redirect
    
    get :create, :topic_id => sessions( :tracs ).topic_id
    assert_response :redirect

    delete :destroy, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs )
    assert_response :redirect    
  end
  
  test "Admins can do anything" do
    login_as( admins( :sean ).login )
    get :show, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs )
    assert_response :success
    
    get :new, :topic_id => sessions( :tracs ).topic_id
    assert_response :success
    
    get :create, :topic_id => sessions( :tracs ).topic_id, :session => { :topic_id => sessions( :tracs ).topic_id }
    assert_response :success

    delete :destroy, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs )
    assert_response :redirect    
  end
  
  test "Instructors can delete sessions" do
    login_as( instructors( :whitten ).login )
    get :show, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs )
    assert_response :success
    
    get :new, :topic_id => sessions( :tracs ).topic_id
    assert_response :redirect
    
    get :create, :topic_id => sessions( :tracs ).topic_id, :session => { :topic_id => sessions( :tracs ).topic_id }
    assert_response :redirect

    delete :destroy, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs )
    assert_response :redirect    
  end
  
  test "Regular users should be able to view, but not make changes" do
    login_as( 'nobodyspecial' )
    get :show, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs )
    assert_response :success
    
    get :new, :topic_id => sessions( :tracs ).topic_id
    assert_response :redirect
    
    get :create, :topic_id => sessions( :tracs ).topic_id, :session => { :topic_id => sessions( :tracs ).topic_id }
    assert_response :redirect

    delete :destroy, :topic_id => sessions( :tracs ).topic_id, :id => sessions( :tracs )
    assert_response :redirect    
  end
  
  test "Should be able to download subscribable calendar without credentials" do
    get :download
    assert_response :success
    assert_equal @response.content_type, 'text/calendar'
  end
    
end
