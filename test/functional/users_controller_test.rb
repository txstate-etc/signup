require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "Verify AJAX handlers for autocompletion are working" do
    get :index, :format => :js
    assert_response :success
  end
end
