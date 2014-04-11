require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "Verify AJAX handlers for autocompletion are working" do
    login_as( users( :admin1 ) )
    get :search, :format => :js, :search => 'plain user'
    assert_response :success
    assert_equal 4, assigns( :users ).size

    get :search, :format => :js, :search => 'pu23456'
    assert_response :success
    assert_equal 1, assigns( :users ).size
  end
  
  test "Login Required for every action" do
    
    %w(search index new create).each do |action|
      get action
      assert_response :redirect
      assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
    end

    # reset the response object or it will give a redirect loop error after five redirects
    setup_controller_request_and_response

    %w(show edit update destroy).each do |action|
      get action, :id => users( :plainuser1 )
      assert_response :redirect
      assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
    end
  end

  test "Admins should be able to do anything." do
    login_as( users( :admin1 ) )
    get :index
    assert_response :success
  
    get :search, :format => :js
    assert_response :success
  
    get :new
    assert_response :success
  
    get :show, :id => users( :plainuser1 )
    assert_response :redirect
    assert_redirected_to root_url

    get :show, :id => users( :editor2 )
    assert_response :redirect
    assert_redirected_to root_url

    get :show, :id => users( :instructor1 )
    assert_response :success

    get :edit, :id => users( :plainuser1 )
    assert_response :success
      
    get :create
    assert_response :success  
    
    put :update, :id => users( :plainuser1 )
    assert_match(/has been updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to users_path

    put :destroy, :id => users( :plainuser1 )
    assert_match(/has been deleted/, flash[:notice])
    assert_response :redirect
    assert_redirected_to users_path
  end
  
  test "Editors can only create and search." do
    login_as( users( :editor1 ) )
    get :index
    assert_response :redirect
    assert_redirected_to root_url
  
    get :search, :format => :js
    assert_response :success
  
    get :new
    assert_response :success
  
    get :show, :id => users( :plainuser1 )
    assert_response :redirect
    assert_redirected_to root_url

    get :show, :id => users( :editor2 )
    assert_response :redirect
    assert_redirected_to root_url

    get :show, :id => users( :instructor1 )
    assert_response :success

    get :edit, :id => users( :plainuser1 )
    assert_response :redirect
    assert_redirected_to root_url
    
    get :create
    assert_response :success  
    
    put :update, :id => users( :plainuser1 )
    assert_no_match(/has been updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to root_url

    put :destroy, :id => users( :plainuser1 )
    assert_no_match(/has been deleted/, flash[:notice])
    assert_response :redirect
    assert_redirected_to root_url
  end

  test "Instructors can only create and search." do
    login_as( users( :instructor1 ) )
    get :index
    assert_response :redirect
    assert_redirected_to root_url
  
    get :search, :format => :js
    assert_response :success
  
    get :new
    assert_response :success
  
    get :show, :id => users( :plainuser1 )
    assert_response :redirect
    assert_redirected_to root_url

    get :show, :id => users( :editor2 )
    assert_response :redirect
    assert_redirected_to root_url

    get :show, :id => users( :instructor1 )
    assert_response :success

    get :edit, :id => users( :plainuser1 )
    assert_response :redirect
    assert_redirected_to root_url
    
    get :create
    assert_response :success  
    
    put :update, :id => users( :plainuser1 )
    assert_no_match(/has been updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to root_url

    put :destroy, :id => users( :plainuser1 )
    assert_no_match(/has been deleted/, flash[:notice])
    assert_response :redirect
    assert_redirected_to root_url
  end

  test "Normal Users can only search." do
    login_as( users( :plainuser1 ) )
    get :index
    assert_response :redirect
    assert_redirected_to root_url
  
    get :search, :format => :js
    assert_response :success
  
    get :new
    assert_response :redirect
    assert_redirected_to root_url
  
    get :show, :id => users( :plainuser1 )
    assert_response :redirect
    assert_redirected_to root_url

    get :show, :id => users( :editor2 )
    assert_response :redirect
    assert_redirected_to root_url

    get :show, :id => users( :instructor1 )
    assert_response :redirect
    assert_redirected_to root_url
      
    get :edit, :id => users( :plainuser1 )
    assert_response :redirect
    assert_redirected_to root_url
    
    get :create
    assert_response :redirect
    assert_redirected_to root_url
    
    put :update, :id => users( :plainuser1 )
    assert_no_match(/has been updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to root_url

    put :destroy, :id => users( :plainuser1 )
    assert_no_match(/has been deleted/, flash[:notice])
    assert_response :redirect
    assert_redirected_to root_url
  end

  test "Show action returns a list of sessions grouped by topic" do
    login_as( users( :admin1 ) )
    get :show, :id => users( :instructor1 )
    assert_response :success

    t = assigns(:topics)
    assert t.is_a? Hash

    assert_equal 6, t.keys.length
    t.each_value { |s| assert s.is_a? Array }
    assert_equal 6, t[topics(:gato)].length
    assert_equal 2, t[topics(:tracs)].length
  end
end
