require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase
  fixtures :admins
  fixtures :instructors
  fixtures :reservations
  fixtures :topics

  # Replace this with your real tests.
  test "Login Required for All Actions" do
    get :new, :session_id => reservations( :bill ).session_id
    assert_response :redirect
    
    get :create, :session_id => reservations( :bill ).session_id
    assert_response :redirect
  end
  
  test "Admins can do anything" do
    login_as( admins( :sean ).login )
    get :new, :session_id => reservations( :bill ).session_id
    assert_response :success
    
    get :create, :session_id => reservations( :bill ).session_id, :session => { :session_id => reservations( :bill ).session_id }
    assert_redirected_to reservations( :bill ).session
    assert Reservation.count == 4
  end
  
end
