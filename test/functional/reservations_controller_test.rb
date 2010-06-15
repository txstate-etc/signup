require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase
  fixtures :admins
  fixtures :instructors
  fixtures :reservations
  fixtures :topics

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
  
  test "Verify that confirmation emails are sent when a reservation is made" do
    login_as( admins( :sean ).login )
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      get :create, :session_id => reservations( :bill ).session_id, :session => { :session_id => reservations( :bill ).session_id }
    end
    
    confirmation_email = ActionMailer::Base.deliveries.first
    assert_equal confirmation_email.subject, "Reservation Confirmation For: sm51"
    assert_equal confirmation_email.to[0], "sm51@txstate.edu"
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
  
  test "Try downloading a reservation as ICS" do
    login_as( reservations( :bill ).login )
    get :download, :id => reservations( :bill )
    assert_response :success
    assert_equal @response.content_type, 'text/calendar'
  end
  
end
