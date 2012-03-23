require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  fixtures :topics, :users
  
  test "Login Required only for New, Create and Update actions" do
    get :index
    assert_response :success
    
    get :show, :id => topics( :gato )
    assert_response :success
    
    get :new
    assert_response :redirect
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
    
    get :create
    assert_response :redirect
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
    
    put :update, :id => topics( :gato )
    assert_response :redirect
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
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
    
    put :update, :id => topics( :gato )
    assert_match(/has been updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to topic_path(assigns(:topic))
  end

  test "Once logged as instructor, should be able to view topics, but not modify them." do
    login_as( users( :instructor1 ) )
    get :index
    assert_response :success
  
    get :show, :id => topics( :gato )
    assert_response :success
    
    get :new
    assert_response :redirect
    assert_redirected_to topics_url
  
    get :create
    assert_response :redirect  
    assert_redirected_to topics_url
    
    put :update, :id => topics( :gato )
    assert_response :redirect
    assert_redirected_to topic_path(assigns(:topic))
  end

  test "Once logged as nobody special, should be able to view topics, but not modify them." do
    login_as( users( :plainuser1 ) )
    get :index
    assert_response :success
  
    get :show, :id => topics( :gato )
    assert_response :success
    
    get :new
    assert_response :redirect
    assert_redirected_to topics_url
  
    get :create
    assert_response :redirect  
    assert_redirected_to topics_url
    
    put :update, :id => topics( :gato )
    assert_response :redirect
    assert_redirected_to topic_path(assigns(:topic))
  end
  
  test "Should be able to download a topic's calendar" do
    get :download, :id => topics( :gato ).id
    assert_response :success
    assert_equal @response.content_type, 'text/calendar'
  end
  
  test "Normal users should only see topics with scheduled sessions" do
    login_as( users( :plainuser1 ) )
    get :index
    assert_equal assigns( :topics ).count, 3
  end
  
  test "Admins should see all topics, regardless of whether courses are scheduled or not" do
    login_as( users( :admin1 ) )
    get :index
    assert_equal assigns( :topics ).count, 5
  end
  
  test "Verify updates working correctly" do
    login_as( users( :admin1 ) )
    put :update, :id => topics( :gato )
    assert_match(/has been updated/, flash[:notice])
    assert_match(/Gato/, assigns(:topic).name)
    assert_response :redirect
    assert_redirected_to topic_path(assigns(:topic))
    
    put :update, :id => topics( :gato ), :topic => { :department => nil }
    assert_match(/problems updating/, flash[:error])
    assert_response :success
  end
  
end

