require 'test_helper'

class DepartmentsControllerTest < ActionController::TestCase
  fixtures :departments, :users

  test "Can get index and detail pages for departments" do
    get :index
    assert_response :success
    assert_equal 5, assigns( :departments ).count

    get :show, :id => departments( :its )
    assert_response :success
    assert_match(/ITS/, assigns(:department).name)
    assert_equal 2, assigns( :topics ).count
    assert_match(/Gato/, assigns(:topics)[0].name)
    assert_match(/TRACS/, assigns(:topics)[1].name)

    get :manage
    assert_response :redirect
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
  
    get :new
    assert_response :redirect
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
    
    get :create
    assert_response :redirect
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
    
    put :update, :id => departments( :its )
    assert_response :redirect
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)

    put :destroy, :id => departments( :its )
    assert_response :redirect
    assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
  end

  test "Admins should be able to do anything." do
    login_as( users( :admin1 ) )
    get :index
    assert_response :success
  
    get :show, :id => departments( :its )
    assert_response :success
      
    get :new
    assert_response :success
  
    get :manage
    assert_response :success
  
    get :create
    assert_response :success  
    
    put :update, :id => departments( :its )
    assert_match(/has been updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to manage_departments_path

    put :destroy, :id => departments( :department_to_make_inactive )
    assert_match(/has been deleted/, flash[:notice])
    assert_response :redirect
    assert_redirected_to manage_departments_path
  end

  test "Editors can look but not touch" do
    login_as( users( :editor1 ) )
    get :index
    assert_response :success

    get :show, :id => departments( :its )
    assert_response :success
      
    get :new
    assert_response :redirect
    assert_redirected_to departments_path
  
    get :manage
    assert_response :redirect
    assert_redirected_to departments_path
  
    get :create
    assert_response :redirect
    assert_redirected_to departments_path
    
    get :edit, :id => departments( :its )
    assert_response :redirect
    assert_redirected_to department_path(assigns(:department))

    put :update, :id => departments( :its )
    assert_no_match(/has been updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to department_path(assigns(:department))

    put :destroy, :id => departments( :department_to_make_inactive )
    assert_no_match(/has been deleted/, flash[:notice])
    assert_response :redirect
    assert_redirected_to department_path(departments( :department_to_make_inactive ))
  end
  
  test "Instructors can look but not touch" do
    login_as( users( :instructor1 ) )
    get :index
    assert_response :success

    get :show, :id => departments( :its )
    assert_response :success
      
    get :new
    assert_response :redirect
    assert_redirected_to departments_path
  
    get :manage
    assert_response :redirect
    assert_redirected_to departments_path
  
    get :create
    assert_response :redirect
    assert_redirected_to departments_path
    
    get :edit, :id => departments( :its )
    assert_response :redirect
    assert_redirected_to department_path(assigns(:department))

    put :update, :id => departments( :its )
    assert_no_match(/has been updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to department_path(assigns(:department))

    put :destroy, :id => departments( :department_to_make_inactive )
    assert_no_match(/has been deleted/, flash[:notice])
    assert_response :redirect
    assert_redirected_to department_path(departments( :department_to_make_inactive ))
  end
  
  test "Normal Users can look but not touch" do
    login_as( users( :plainuser1 ) )
    get :index
    assert_response :success

    get :show, :id => departments( :its )
    assert_response :success
      
    get :new
    assert_response :redirect
    assert_redirected_to departments_path
  
    get :manage
    assert_response :redirect
    assert_redirected_to departments_path
  
    get :create
    assert_response :redirect
    assert_redirected_to departments_path
    
    get :edit, :id => departments( :its )
    assert_response :redirect
    assert_redirected_to department_path(assigns(:department))

    put :update, :id => departments( :its )
    assert_no_match(/has been updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to department_path(assigns(:department))

    put :destroy, :id => departments( :department_to_make_inactive )
    assert_no_match(/has been deleted/, flash[:notice])
    assert_response :redirect
    assert_redirected_to department_path(departments( :department_to_make_inactive ))
  end
  
  test "Verify updates working correctly" do
    login_as( users( :admin1 ) )
    put :update, :id => departments( :its )
    assert_match(/has been updated/, flash[:notice])
    assert_match(/ITS/, assigns(:department).name)
    assert_response :redirect
    assert_redirected_to manage_departments_path
    
    put :update, :id => departments( :its ), :department => { :name => nil }
    assert_match(/problems updating/, flash[:error])
    assert_response :success
  end
  
  test "Admins can manage any department" do
    login_as( users( :admin1 ) )
    get :manage
    assert_response :success
    assert_equal 5, assigns( :departments ).count
  end
  
  test "Editors cannot manage departments" do
    login_as( users( :editor1 ) )

    get :manage
    assert_response :redirect
    assert_redirected_to departments_path
  end

  test "Instructors cannot manage departments" do
    login_as( users( :instructor1 ) )

    get :manage
    assert_response :redirect
    assert_redirected_to departments_path
  end
    
  test "Normal users cannot manage departments" do
    login_as( users( :plainuser1 ) )
    
    get :manage
    assert_response :redirect
    assert_redirected_to departments_path
  end

  test "Only editors and admins should be able to download attendance history" do
    login_as( users( :plainuser1 ) )
    get :show, :id => departments( :its ), :format => 'csv'
    assert_response 406, "Should NOT be able to download attendance history"
    assert_equal 1, @response.body.length

    login_as( users( :instructor1 ) )
    get :show, :id => departments( :its ), :format => 'csv'
    assert_response 406, "Should NOT be able to download attendance history"
    assert_equal 1, @response.body.length

    login_as( users( :admin1 ) )
    get :show, :id => departments( :its ), :format => 'csv'
    assert_response :success
    assert_equal 'text/csv', @response.content_type

    login_as( users( :editor1 ) )
    get :show, :id => departments( :its ), :format => 'csv'
    assert_response :success
    assert_equal 'text/csv', @response.content_type
    
    get :show, :id => departments( :tr ), :format => 'csv'
    assert_response 406, "Should NOT be able to download attendance history"
    assert_equal 1, @response.body.length
  end
end
