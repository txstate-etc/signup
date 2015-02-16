require 'test_helper'

class DepartmentsControllerTest < ActionController::TestCase
  fixtures :departments, :users

  test "Can get index and detail pages for departments" do
    get :index
    assert_response :success

    get :show, :id => departments( :its )
    assert_response :success
    assert_match(/ITS/, assigns(:department).name)

    get :manage
    assert_response :redirect
    assert_redirected_to "/auth/cas?url=#{@request.url}"
  
    get :new
    assert_response :redirect
    assert_redirected_to "/auth/cas?url=#{@request.url}"
    
    post :create, department: { name: 'New Name' }
    assert_response :redirect
    assert_redirected_to "/auth/cas?url=#{@request.url}"
    
    put :update, :id => departments( :its )
    assert_response :redirect
    assert_redirected_to "/auth/cas?url=#{@request.url}"

    put :destroy, :id => departments( :its )
    assert_response :redirect
    assert_redirected_to "/auth/cas?url=#{@request.url}"
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
  
    post :create, department: { name: 'New Department' }
    assert_match(/was successfully created/, flash[:notice])
    assert_response :redirect
    assert_redirected_to manage_departments_path
    
    put :update, :id => departments( :its ), department: { name: 'New Name' }
    assert_match(/was successfully updated/, flash[:notice])
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
  
    post :create, department: { name: 'New Name' }
    assert_response :redirect
    assert_redirected_to departments_path
    
    get :edit, :id => departments( :its )
    assert_response :redirect
    assert_redirected_to departments_path

    put :update, :id => departments( :its )
    assert_no_match(/has been updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to departments_path

    put :destroy, :id => departments( :department_to_make_inactive )
    assert_no_match(/has been deleted/, flash[:notice])
    assert_response :redirect
    assert_redirected_to departments_path
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
  
    post :create, department: { name: 'New Name' }
    assert_response :redirect
    assert_redirected_to departments_path
    
    get :edit, :id => departments( :its )
    assert_response :redirect
    assert_redirected_to departments_path

    put :update, :id => departments( :its )
    assert_no_match(/has been updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to departments_path

    put :destroy, :id => departments( :department_to_make_inactive )
    assert_no_match(/has been deleted/, flash[:notice])
    assert_response :redirect
    assert_redirected_to departments_path
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
  
    post :create, department: { name: 'New Name' }
    assert_response :redirect
    assert_redirected_to departments_path
    
    get :edit, :id => departments( :its )
    assert_response :redirect
    assert_redirected_to departments_path

    patch :update, :id => departments( :its ), department: { name: 'New Name' }
    assert_no_match(/was successfully updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to departments_path

    put :destroy, :id => departments( :department_to_make_inactive )
    assert_no_match(/was successfully updated/, flash[:notice])
    assert_response :redirect
    assert_redirected_to departments_path
  end
  
  test "Verify updates working correctly" do
    login_as( users( :admin1 ) )
    patch :update, id: departments( :its ), department: { name: 'New Name' }
    assert_match /was successfully updated/, flash[:notice]
    assert_equal 'New Name', assigns(:department).name
    assert_response :redirect
    assert_redirected_to manage_departments_path
    
    patch :update, :id => departments( :its ), :department => { :name => nil }
    assert_match(/problems updating/, flash[:alert])
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
    assert_raises ActionController::UnknownFormat, 'Should NOT be able to download attendance history' do
      get :show, :id => departments( :its ), :format => 'csv'
    end
    assert_equal 0, @response.body.length

    login_as( users( :instructor1 ) )
    assert_raises ActionController::UnknownFormat, 'Should NOT be able to download attendance history' do
      get :show, :id => departments( :its ), :format => 'csv'
    end
    assert_equal 0, @response.body.length

    login_as( users( :admin1 ) )
    get :show, :id => departments( :its ), :format => 'csv'
    assert_response :success
    assert_match %r{text/csv}, @response.content_type

    login_as( users( :editor1 ) )
    get :show, :id => departments( :its ), :format => 'csv'
    assert_response :success
    assert_match %r{text/csv}, @response.content_type
    
    assert_raises ActionController::UnknownFormat, 'Should NOT be able to download attendance history' do
      get :show, :id => departments( :tr ), :format => 'csv'
    end
    assert_equal 0, @response.body.length
  end

end
