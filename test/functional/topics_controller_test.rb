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
  
  test "Admins should only see topics with scheduled sessions" do
    login_as( users( :admin1 ) )
    get :index
    assert_equal assigns( :topics ).count, 3
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
  
  test "Admins can manage any topic" do
    login_as( users( :admin1 ) )
    @request.session[ :topics ] = 'all'
    @request.session[ :departments ] = 'all'
    get :manage
    assert_response :success
    assert_equal 3, assigns( :departments ).count
    assert_equal 5, assigns( :topics ).count
  end
  
  test "Editors can manage topics in their department" do
    login_as( users( :editor1 ) )
    get :manage
    assert_response :success
    assert_equal 1, assigns( :departments ).count
    assert_equal 3, assigns( :topics ).count
  end
  
  test "Instructors can manage topics they are instructors for" do
    login_as( users( :instructor1 ) )
    @request.session[ :topics ] = 'all'
    @request.session[ :departments ] = 'all'
    get :manage
    assert_response :success
    assert_equal 2, assigns( :departments ).count
    assert_equal 4, assigns( :topics ).count

    login_as( users( :instructor2 ) )
    get :manage
    assert_response :success
    assert_equal 1, assigns( :departments ).count
    assert_equal 1, assigns( :topics ).count
  end
  
  test "Normal users cannot manage topics" do
    login_as( users( :plainuser1 ) )
    get :manage
    assert_response :redirect
    assert_redirected_to topics_url
  end
  
end

