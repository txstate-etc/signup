require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase
  fixtures :users
  fixtures :reservations
  fixtures :topics

  test "Login Required for All Actions" do
    get :new, :session_id => reservations( :plainuser1 ).session_id
    assert_response :redirect
    
    get :create, :session_id => reservations( :plainuser1 ).session_id
    assert_response :redirect
    
    delete :destroy, :id => reservations( :plainuser1 )
    assert_response :redirect
  end
  
  test "Try making reservations" do
    login_as( users( :admin1 ) )
    get :new, :session_id => reservations( :plainuser1 ).session_id
    assert_response :success
    
    get :create, :session_id => reservations( :plainuser1 ).session_id, :session => { :session_id => reservations( :plainuser1 ).session_id }
    assert_redirected_to reservations( :plainuser1 ).session
    assert_equal 7, Reservation.count, "Couldn't create reservation"
  end
  
  test "Verify that confirmation emails are sent when a reservation is made" do
    login_as( users( :admin1 ) )
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      get :create, :session_id => reservations( :plainuser1 ).session_id, :session => { :session_id => reservations( :plainuser1 ).session_id }
    end
    
    confirmation_email = ActionMailer::Base.deliveries.first
    assert_equal confirmation_email.subject, "Reservation Confirmation For: Admin1"
    assert_equal confirmation_email.to[0], "a12345@dev.nul"
  end
  
  test "Users should only be able to delete their own reservations" do
    login_as( users( :plainuser1 ) )
    delete :destroy, :id => reservations( :plainuser1 )
    assert_response :redirect
    assert_equal 5, Reservation.count
    
    delete :destroy, :id => reservations( :plainuser3 )
    assert_response :redirect
    assert_equal 5, Reservation.count, "One user was able to delete another's reservation."
  end
  
  test "Show what training sessions user is registered for" do
    login_as( users( :plainuser1 ) )
    get :index
    assert_equal 2,  assigns( :reservations ).size, "Number of upcoming sessions for Plainuser1 was incorrect."
    assert_response :success
  end
  
  test "Try downloading a reservation as ICS" do
    login_as( users( :plainuser1 ) )
    get :download, :id => reservations( :plainuser1 )
    assert_response :success
    assert_equal @response.content_type, 'text/calendar'
  end
  
end
