require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  fixtures :topics, :users
  
  test "Login Required for All Actions" do
    get :index
    assert_response :redirect
    
    get :show, :id => topics( :gato )
    assert_response :redirect
    
    get :new
    assert_response :redirect
    
    get :create
    assert_response :redirect
  end

  test "Admins should be able to do anything." do
    login_as( users( :admin1 ) )
    get :index
    assert_response :success
  
    get :show, :id => topics( :gato )
    assert_response :success
      
    get :new
    assert_response :success
  
    get :create
    assert_response :success  
  end

  test "Once logged as instructor, should be able to view topics, but not modify them." do
    login_as( users( :instructor1 ) )
    get :index
    assert_response :success
  
    get :show, :id => topics( :gato )
    assert_response :success
    
    get :new
    assert_response :redirect
  
    get :create
    assert_response :redirect  
  end

  test "Once logged as nobody special, should be able to view topics, but not modify them." do
    login_as( users( :plainuser1 ) )
    get :index
    assert_response :success
  
    get :show, :id => topics( :gato )
    assert_response :success
    
    get :new
    assert_response :redirect
  
    get :create
    assert_response :redirect  
  end
  
  test "Should be able to download a topic's calendar" do
    get :download, :id => topics( :gato ).id
    assert_response :success
    assert_equal @response.content_type, 'text/calendar'
  end
  
end

