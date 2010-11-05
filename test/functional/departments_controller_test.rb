require 'test_helper'

class DepartmentsControllerTest < ActionController::TestCase
  fixtures :departments
  # Replace this with your real tests.
  test "Can get index and detail pages for departments" do
    get :index
    assert_response :success

    get :show, :id => departments( :its )
    assert_response :success
  end
end
