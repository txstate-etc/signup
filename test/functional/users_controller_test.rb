require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "Verify AJAX handlers for autocompletion are working" do
    get :index, :format => :js, :search => 'plain user'
    assert_response :success
    assert_equal 4, assigns( :users ).size

    get :index, :format => :js, :search => 'pu23456'
    assert_response :success
    assert_equal 1, assigns( :users ).size
  end
end
