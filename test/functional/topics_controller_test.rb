require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  fixtures :topics, :users
  
  test "Login Required only for New, Create and Update actions" do
    get :index
    assert_response :success
    
    get :grid
    assert_response :success

    get :upcoming
    assert_response :redirect
    assert_redirected_to root_path

    get :by_department
    assert_response :success

    get :show, :id => topics( :gato )
    assert_response :success
    
    get :manage
    assert_response :redirect
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
  
    get :manage_topic, :id => topics( :gato )
    assert_response :redirect
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)

    get :new
    assert_response :redirect
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
    
    get :create
    assert_response :redirect
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
    
    put :update, :id => topics( :gato )
    assert_response :redirect
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)

    # reset the response object or it will give a redirect loop error after five redirects
    setup_controller_request_and_response

    put :destroy, :id => topics( :gato )
    assert_response :redirect
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
  end

  test "Admins should be able to do anything." do
    login_as( users( :admin1 ) )
    get :index
    assert_response :success
  
    get :grid
    assert_response :success

    get :upcoming
    assert_response :redirect
    assert_redirected_to root_path

    get :by_department
    assert_response :success

    get :show, :id => topics( :gato )
    assert_response :success
      
    get :new
    assert_response :success
  
    get :manage
    assert_response :success
  
    get :create
    assert_response :success  
    
    put :update, :id => topics( :gato )
    assert_match(/has been updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to topic_path(assigns(:topic))

    put :destroy, :id => topics( :topic_to_make_inactive )
    assert_match(/has been deleted/, flash[:notice])
    assert_response :redirect
    assert_redirected_to manage_topics_path
  end

  test "Editors should be able to do anything in their departments." do
    login_as( users( :editor1 ) )
    get :index
    assert_response :success
  
    get :grid
    assert_response :success

    get :upcoming
    assert_response :redirect
    assert_redirected_to root_path

    get :by_department
    assert_response :success

    get :show, :id => topics( :gato )
    assert_response :success
      
    get :new
    assert_response :success
  
    get :manage
    assert_response :success
  
    get :create
    assert_response :success  
    
    get :edit, :id => topics( :gato )
    assert_response :success

    put :update, :id => topics( :gato )
    assert_match(/has been updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to topic_path(assigns(:topic))

    get :delete, :id => topics( :topic_to_make_inactive )
    assert_response :success

    put :destroy, :id => topics( :topic_to_make_inactive )
    assert_match(/has been deleted/, flash[:notice])
    assert_response :redirect
    assert_redirected_to manage_topics_path
  end

  test "Editors should NOT be able to do anything in other departments." do
    login_as( users( :editor1 ) )

    get :edit, :id => topics( :no_survey_topic )
    assert_response :redirect
    assert_redirected_to topic_path(assigns(:topic))
        
    get :delete, :id => topics( :no_survey_topic )
    assert_response :redirect
    assert_redirected_to topic_path(assigns(:topic))
        
    put :update, :id => topics( :no_survey_topic )
    assert_no_match(/has been updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to topic_path(assigns(:topic))

    put :destroy, :id => topics( :topic_to_delete )
    assert_no_match(/has been deleted/, flash[:notice])
    assert_response :redirect
    assert_redirected_to topics( :topic_to_delete )
  end

  test "Once logged as instructor, should be able to view topics, but not modify them." do
    login_as( users( :instructor1 ) )
    get :index
    assert_response :success

    get :grid
    assert_response :success

    get :upcoming
    assert_response :redirect
    assert_redirected_to root_path

    get :by_department
    assert_response :success

    get :show, :id => topics( :gato )
    assert_response :success
    
    get :manage
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

    put :destroy, :id => topics( :topic_to_make_inactive )
    assert_response :redirect
    assert_redirected_to topic_path(topics( :topic_to_make_inactive ))
    assert_equal false, topics( :topic_to_make_inactive ).inactive
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

    put :destroy, :id => topics( :topic_to_make_inactive )
    assert_response :redirect
    assert_redirected_to topic_path(topics( :topic_to_make_inactive ))
    assert_equal false, topics( :topic_to_make_inactive ).inactive
  end
  
  test "Should be able to download a topic's calendar" do
    get :download, :id => topics( :gato ).id
    assert_response :success
    assert_equal @response.content_type, 'text/calendar'
  end
  
  # FIXME: not sure how to test alpha now that nothing happens in the controller
  # test "Normal users should only see topics with scheduled sessions" do
  #   login_as( users( :plainuser1 ) )
  #   get :alpha
  #   assert_equal assigns( :topics ).count, 3
  # end
  
  # test "Admins should only see topics with scheduled sessions" do
  #   login_as( users( :admin1 ) )
  #   get :alpha
  #   assert_equal assigns( :topics ).count, 3
  # end
  
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
    assert_equal 5, assigns( :topics ).keys.size
    assert_equal 7, assigns( :topics ).values.reduce(0){ |s,a| s+a.size }

    get :manage_topic, :id => topics( :gato )
    assert_response :success

  end
  
  test "Editors can manage topics in their department" do
    login_as( users( :editor1 ) )
    @request.session[ :topics ] = 'all'
    @request.session[ :departments ] = 'all'
    get :manage
    assert_response :success
    assert_equal 2, assigns( :topics ).keys.size
    assert_equal 4, assigns( :topics ).values.reduce(0){ |s,a| s+a.size }

    get :manage_topic, :id => topics( :gato )
    assert_response :success, "Should be able to manage topic in his department"

    get :manage_topic, :id => topics( :topic_with_attached_documents )
    assert_response :success, "Should be able to manage topic he is an instructor for"

    get :manage_topic, :id => topics( :multi_time_topic )
    assert_response :redirect, "Should NOT be able to manage topic in other departments"
    assert_redirected_to topics_path

    login_as( users( :editor2 ) )
    get :manage
    assert_response :success
    assert_equal 2, assigns( :topics ).keys.size
    assert_equal 7, assigns( :topics ).values.reduce(0){ |s,a| s+a.size }
  end
  
  test "Instructors can manage topics they are instructors for" do
    login_as( users( :instructor1 ) )
    @request.session[ :topics ] = 'all'
    @request.session[ :departments ] = 'all'
    get :manage
    assert_response :success
    assert_equal 3, assigns( :topics ).keys.size
    assert_equal 6, assigns( :topics ).values.reduce(0){ |s,a| s+a.size }

    get :manage_topic, :id => topics( :gato )
    assert_response :success, "Should be able to manage topic he is an instructor for"

    get :manage_topic, :id => topics( :topic_with_attached_documents )
    assert_response :redirect, "Should NOT be able to manage topic he is not an instructor for"
    assert_redirected_to topics_path

    login_as( users( :instructor2 ) )
    get :manage
    assert_response :success
    assert_equal 1, assigns( :topics ).keys.size
    assert_equal 1, assigns( :topics ).values.reduce(0){ |s,a| s+a.size }
  end
  
  test "Normal users cannot manage topics" do
    login_as( users( :plainuser1 ) )
    get :manage
    assert_response :redirect
    assert_redirected_to topics_url

    get :manage_topic, :id => topics( :gato )
    assert_response :redirect, "Should NOT be able to manage any topic"
    assert_redirected_to topics_path

  end

  test "Only editors and admins should be able to download attendance history" do
    login_as( users( :plainuser1 ) )
    get :show, :id => topics(:gato), :format => 'csv'
    assert_response 406, "Should NOT be able to download attendance history"
    assert_equal 1, @response.body.length

    login_as( users( :instructor1 ) )
    get :show, :id => topics(:gato), :format => 'csv'
    assert_response 406, "Should NOT be able to download attendance history"
    assert_equal 1, @response.body.length

    login_as( users( :admin1 ) )
    get :show, :id => topics(:gato), :format => 'csv'
    assert_response :success
    assert_equal 'text/csv', @response.content_type

    login_as( users( :editor1 ) )
    get :show, :id => topics(:gato), :format => 'csv'
    assert_response :success
    assert_equal 'text/csv', @response.content_type
    
    get :show, :id => topics(:multi_time_topic), :format => 'csv'
    assert_response 406, "Should NOT be able to download attendance history"
    assert_equal 1, @response.body.length
  end

  test "Grid view shows the correct month" do
    get :grid
    assert_response :success
    assert_equal Date.today.beginning_of_month, assigns(:cur_month)
    
    get :grid, :month => '03', :year => '2010'
    assert_response :success
    assert_equal "2010-03-01", assigns(:cur_month).strftime('%Y-%m-%d') 
  end

  test "Grid view shows the correct occurrences for the selected month" do
    get :grid, :month => '06', :year => '2035'
    assert_response :success
    assert_equal "2035-06-01", assigns(:cur_month).strftime('%Y-%m-%d')
 
    get :grid, :month => '05', :year => '2045'
    assert_response :success
    assert_equal "2045-05-01", assigns(:cur_month).strftime('%Y-%m-%d')
  end
    
end

