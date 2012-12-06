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
end
