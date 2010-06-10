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
    
    delete :destroy, :id => reservations( :bill )
    assert_response :redirect
  end
  
  test "Try making reservations" do
    login_as( admins( :sean ).login )
    get :new, :session_id => reservations( :bill ).session_id
    assert_response :success
    
    get :create, :session_id => reservations( :bill ).session_id, :session => { :session_id => reservations( :bill ).session_id }
    assert_redirected_to reservations( :bill ).session
    assert Reservation.count == 4
  end
  
  test "Users should only be able to delete their own reservations" do
    login_as( reservations( :bill ).login )
    delete :destroy, :id => reservations( :bill )
    assert_response :redirect
    assert_equal Reservation.count, 2
    
    delete :destroy, :id => reservations( :joey )
    assert_response :redirect
    assert_equal Reservation.count, 2, "Bill was able to delete Joey's reservation"
  end
  
  test "Show what training sessions user is registered for" do
    login_as( reservations( :bill ).login )
    get :index
    assert assigns( :reservations ).size == 1
    assert_response :success
  end
  
end
