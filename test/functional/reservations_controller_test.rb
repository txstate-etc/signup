require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase
  fixtures :users
  fixtures :reservations
  fixtures :topics
  fixtures :sessions

  test "Login Required for All Actions" do
    get :new, :session_id => reservations( :plainuser1 ).session_id
    assert_response :redirect
    
    get :create, :session_id => reservations( :plainuser1 ).session_id
    assert_response :redirect
    
    delete :destroy, :id => reservations( :plainuser1 )
    assert_response :redirect
  end
  
  test "Try making reservations" do
    login_as( users( :plainuser3 ) )
    get :new, :session_id => sessions( :gato )
    assert_response :success
    
    assert_difference 'Reservation.count', + 1, "Couldn't create reservation" do
      get :create, :session_id => sessions( :gato ), :session => { :session_id => sessions( :gato ) }
    end
    assert_redirected_to sessions( :gato )
  end
  
  test "Ensure special accommodations are recorded" do
    login_as( users( :plainuser3 ) )
    accommodation = "I need a seeing-eye buffalo"
    
    get :create, :session_id => sessions( :gato ), :session => { :session_id => sessions( :gato ) }, :reservation => { :special_accommodations => accommodation }
    assert_equal assigns( :reservation ).special_accommodations, accommodation
  end
  
  test "Admin should be able to make a reservation on someone else's behalf" do
    login_as( users( :admin1 ) )
    assert_difference 'Reservation.count', +1, "Admin couldn't create reservation" do
      get :create, :session_id => sessions( :gato ), :session => { :session_id => sessions( :gato) }, :user_login => users( :plainuser3 ).login
    end
    assert_redirected_to sessions( :gato )
    assert_equal assigns( :reservation ).user, users( :plainuser3 ), "Admin made reservation for plainuser3, but it wasn't recorded as plainuser3"
  end
  
  test "Verify that confirmation emails are sent when a reservation is made" do
    login_as( users( :plainuser3 ) )
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      get :create, :session_id => sessions( :gato ), :session => { :session_id => sessions( :gato ) }
    end
    
    confirmation_email = ActionMailer::Base.deliveries.last
    assert_equal confirmation_email.subject, "Reservation Confirmation For: Plain User3"
    assert_equal confirmation_email.to[0], "pu34567@dev.nul"
  end
  
  test "Users should only be able to delete their own reservations" do
    login_as( users( :plainuser1 ) )
    assert_difference 'Reservation.count', -1 do
      delete :destroy, :id => reservations( :plainuser1 )
    end
    assert_response :redirect
    
    assert_difference 'Reservation.count', 0, "One user was able to delete another's reservation." do
      delete :destroy, :id => reservations( :plainuser3 )
    end
    assert_response :redirect
  end
  
  test "Users should only be able to delete reservations before the class has begun" do
    login_as( users( :plainuser1 ) )
    assert_difference 'Reservation.count', 0, "User was able to delete a reservation from the past." do
      delete :destroy, :id => reservations( :gato_past_plainuser1 )
    end
    assert_response :redirect
  end
  
  test "Admins should be able to delete a user's reservation" do
    login_as( users( :admin1 ) )
    assert_difference 'Reservation.count', -1 do
      delete :destroy, :id => reservations( :plainuser1 )
    end
    assert_response :redirect
  end
  
  test "The instructor for a session should be able to delete a user's reservation" do
    login_as( users( :instructor1 ) )
    assert_difference 'Reservation.count', -1 do
      delete :destroy, :id => reservations( :plainuser1 )
    end
    assert_response :redirect
  end
  
  test "Deleting a reservation with no waiting list shouldn't trigger any emails" do
    login_as( users( :plainuser1 ) )
    assert_difference 'ActionMailer::Base.deliveries.size', +0 do
      delete :destroy, :id => reservations( :plainuser1 )
    end
  end
  
  test "When a reservation is deleted, the first person in the waiting list should be promoted and get an email" do
    login_as( users( :plainuser1 ) )
    
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      delete :destroy, :id => reservations( :overbooked_plainuser1 )
    end
    
    promotion_email = ActionMailer::Base.deliveries.last
    assert_equal "Now Enrolled: " + topics( :gato ).name, promotion_email.subject
    assert_equal users( :plainuser3 ).email, promotion_email.to[0]
    
    assert_equal 0, sessions( :gato_overbooked ).waiting_list.size
    assert_equal 2, sessions( :gato_overbooked ).confirmed_reservations.size
  end
  
  test "Show what training sessions user is registered for" do
    login_as( users( :plainuser1 ) )
    get :index
    assert_equal 6,  assigns( :confirmed_reservations ).size, "Number of upcoming sessions for Plainuser1 was incorrect."
    assert_equal 3,  assigns( :past_reservations ).size, "Number of past sessions for Plainuser1 was incorrect."
    assert_equal 0,  assigns( :waiting_list_signups ).size, "Number of wait listed sessions for Plainuser1 was incorrect."
    assert_response :success

    login_as( users( :plainuser2 ) )
    get :index
    assert_equal 2,  assigns( :confirmed_reservations ).size, "Number of upcoming sessions for Plainuser2 was incorrect."
    assert_equal 3,  assigns( :past_reservations ).size, "Number of past sessions for Plainuser2 was incorrect."
    assert_equal 0,  assigns( :waiting_list_signups ).size, "Number of wait listed sessions for Plainuser2 was incorrect."
    assert_response :success
    
    login_as( users( :plainuser3 ) )
    get :index
    assert_equal 1,  assigns( :confirmed_reservations ).size, "Number of upcoming sessions for Plainuser3 was incorrect."
    assert_equal 0,  assigns( :past_reservations ).size, "Number of past sessions for Plainuser3 was incorrect."
    assert_equal 1,  assigns( :waiting_list_signups ).size, "Number of wait listed sessions for Plainuser3 was incorrect."
    assert_response :success
  end
  
  test "Cancelled sessions shouldn't show up on a user's reservation list" do
    login_as( users( :plainuser3 ) )
    get :index
    assert_equal 1,  assigns( :confirmed_reservations ).size, "Number of upcoming sessions for Plainuser3 was incorrect."
    assert_response :success    
  end
  
  test "Try downloading a reservation as ICS" do
    login_as( users( :plainuser1 ) )
    get :download, :id => reservations( :plainuser1 )
    assert_response :success
    assert_equal @response.content_type, 'text/calendar'
  end
  
end
