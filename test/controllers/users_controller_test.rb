require 'test_helper'

# FIXME: we should mock up the LDAP search

class UsersControllerTest < ActionController::TestCase
  # test "Verify AJAX handlers for autocompletion are working" do
  #   login_as( users( :admin1 ) )
  #   get :autocomplete_search, :term => 'john'
  #   assert_response :success
  #   assert_match %r{application/json}, @response.content_type
  #   json = JSON.parse @response.body
  #   assert_equal 11, json.size
  #   assert_equal 'add-new', json.last['id']
  #   assert_equal 'Add new...', json.last['label']
  #   assert_match /^John/i, json.first['label']
  #   assert_match /^John/i, json.first['value']

  #   get :autocomplete_search, :term => 'cj32'
  #   assert_response :success
  #   assert_match %r{application/json}, @response.content_type
  #   json = JSON.parse @response.body
  #   assert_includes 2..11, json.size
  #   assert_includes json.map { |i| i['id'] }, 'cj32'

  # end
  
  test "Login Required for every action" do
    
    %w(autocomplete_search index new create).each do |action|
      get action
      assert_response :redirect
      assert_redirected_to "/auth/cas?url=#{@request.url}"
    end

    # reset the response object or it will give a redirect loop error after five redirects
    setup_controller_request_and_response

    %w(show edit update destroy).each do |action|
      get action, :id => users( :plainuser1 )
      assert_response :redirect
      assert_redirected_to "/auth/cas?url=#{@request.url}"
    end
  end

  test "Admins should be able to do anything." do
    login_as( users( :admin1 ) )
    get :index
    assert_response :success
  
    get :autocomplete_search, :term => 'plain user'
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
      
    post :create, :user => { :login => 'diehard', :first_name => 'John', :last_name => 'McClain', :email => 'yippiekiyay@nakatomi.com' }
    assert_response :redirect
    assert_redirected_to users_path
    
    patch :update, :id => users( :plainuser1 ), :user => { :first_name => 'John' }
    assert_match(/was successfully updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to users_path

    delete :destroy, :id => users( :plainuser1 )
    assert_match(/was successfully deleted/, flash[:notice])
    assert_response :redirect
    assert_redirected_to users_path
  end
  
  test "Editors can only create and search." do
    login_as( users( :editor1 ) )
    get :index
    assert_response :redirect
    assert_redirected_to root_url
  
    get :autocomplete_search, :term => 'plain user'
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
    
    post :create, :user => { :login => 'diehard', :first_name => 'John', :last_name => 'McClain', :email => 'yippiekiyay@nakatomi.com' }
    assert_response :redirect
    assert_redirected_to users_path
   
    patch :update, :id => users( :plainuser1 ), :user => { :first_name => 'John' }
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
  
    get :autocomplete_search, :term => 'plain user'
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
    
    post :create, :user => { :login => 'diehard', :first_name => 'John', :last_name => 'McClain', :email => 'yippiekiyay@nakatomi.com' }
    assert_response :redirect
    assert_redirected_to users_path
    
    patch :update, :id => users( :plainuser1 ), :user => { :first_name => 'John' }
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
  
    get :autocomplete_search, :term => 'plain user'
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
    
    post :create, :user => { :first_name => 'John', :last_name => 'McClain', :email => 'yippiekiyay@nakatomi.com' }
    assert_response :redirect
    assert_redirected_to root_url
    
    patch :update, :id => users( :plainuser1 ), :user => { :first_name => 'John' }
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
