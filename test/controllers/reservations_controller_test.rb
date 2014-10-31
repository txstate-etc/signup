require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase
  fixtures :users
  fixtures :reservations
  fixtures :topics
  fixtures :sessions

  def setup
    Reservation.counter_culture_fix_counts
  end

  test "Login Required for All Actions" do
    assert_raises ActionController::UrlGenerationError do
      get :new, :session_id => reservations( :plainuser1 ).session_id
    end

    post :create, :session_id => reservations( :plainuser1 ).session_id
    assert_response :redirect

    get :edit, :id => reservations( :plainuser1 )
    assert_response :redirect

    patch :update, :id => reservations( :plainuser1 ), :reservation => { :special_accommodations => 'some thing' }
    
    delete :destroy, :id => reservations( :plainuser1 )
    assert_response :redirect

    get :send_reminder, :id => reservations( :plainuser1 )
    assert_response :redirect
  end
  
  #FIXME: we need an authentication_controller_test
  # test "Failed login causes redirect and error message" do
  #   @request.session[ :auth_user ] = 'fake_user'
  #   get :edit, :id => reservations( :plainuser1 )
  #   assert_redirected_to root_url
  #   assert_equal "Oops! We could not log you in. If you just received your login ID, you may need to wait 24 hours before it's available.", flash[:error]
  # end
    
  test "Try making reservations" do
    login_as( users( :plainuser3 ) )
    
    assert_difference 'Reservation.active.count', + 1, "Couldn't create reservation" do
      post :create, :session_id => sessions( :tracs )
    end
    assert_redirected_to sessions( :tracs )
  end

  test "Try editing reservations" do
    login_as( users( :plainuser1 ) )
    get :edit, :id => reservations( :plainuser1 )
    assert_response :success
    
    accommodation = 'I need a seeing-eye buffalo'
    patch :update, :id => reservations( :plainuser1 ), :reservation => { :special_accommodations => accommodation }
    assert_redirected_to sessions( :gato )
    assert_match /was successfully updated/, flash[:notice]
    assert_equal accommodation, assigns( :reservation ).special_accommodations
  end
  
  test "Ensure special accommodations are recorded" do
    login_as( users( :plainuser3 ) )
    accommodation = "I need a seeing-eye buffalo"
    
    post :create, :session_id => sessions( :tracs ), :session => { :session_id => sessions( :tracs ) }, :reservation => { :special_accommodations => accommodation }
    assert_match /has been confirmed/, flash[:notice]
    assert_equal accommodation, assigns( :reservation ).special_accommodations
  end
  
  test "Admin should be able to make a reservation on someone else's behalf" do
    login_as( users( :admin1 ) )
    assert_difference 'Reservation.active.count', +1, "Admin couldn't create reservation" do
      post :create, :session_id => sessions( :tracs ), :session => { :session_id => sessions( :tracs) }, :user_login => users( :plainuser3 ).login
    end
    assert_redirected_to sessions_reservations_path( sessions( :tracs ) )
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
    assert_difference 'Reservation.active.count', -1 do
      delete :destroy, :id => reservations( :plainuser1 )
    end
    assert_response :redirect
    
    assert_difference 'Reservation.active.count', 0, "One user was able to delete another's reservation." do
      delete :destroy, :id => reservations( :plainuser3 )
    end
    assert_response :redirect
  end
  
  test "Users should only be able to delete reservations before the class has begun" do
    login_as( users( :plainuser1 ) )
    assert_difference 'Reservation.active.count', 0, "User was able to delete a reservation from the past." do
      delete :destroy, :id => reservations( :gato_past_plainuser1 )
    end
    assert_response :redirect
  end
  
  test "Admins should be able to delete a user's reservation" do
    login_as( users( :admin1 ) )
    assert_difference 'Reservation.active.count', -1 do
      delete :destroy, :id => reservations( :plainuser1 )
    end
    assert_response :redirect
  end
  
  test "Editors should be able to delete a user's reservation in their department" do
    login_as( users( :editor1 ) )
    assert_difference 'Reservation.active.count', -1 do
      delete :destroy, :id => reservations( :plainuser1 )
    end
    assert_response :redirect
  end
  
  test "Editors should NOT be able to delete a user's reservation in other departments" do
    login_as( users( :editor1 ) )
    assert_difference 'Reservation.active.count', +0 do
      delete :destroy, :id => reservations( :no_survey_topic_past_plainuser1 )
    end
    assert_response :redirect
  end
  
  test "The instructor for a session should be able to delete a user's reservation" do
    login_as( users( :instructor1 ) )
    assert_difference 'Reservation.active.count', -1 do
      delete :destroy, :id => reservations( :plainuser1 )
    end
    assert_response :redirect
  end
  
  test "The instructor should NOT be able to delete a user's reservation for sessions he is not the instructor for" do
    login_as( users( :instructor2 ) )
    assert_difference 'Reservation.active.count', +0 do
      delete :destroy, :id => reservations( :plainuser1 )
    end
    assert_response :redirect
  end
  
  test "Only admins, editors, and instructors should be able to send reminders" do
    reservation = reservations( :plainuser1 )
    login_as( users( :plainuser2 ) )
    get :send_reminder, :id => reservation
    assert_response :redirect
    assert_redirected_to root_url
    assert_match /Reminders can only be sent by their owner, an admin, or an instructor/, flash[:alert]
  
    login_as( users( :plainuser1 ) )
    get :send_reminder, :id => reservation
    assert_response :redirect
    assert_redirected_to reservations_path
    assert_match /A reminder has been sent to/, flash[:notice]
    get :send_reminder, :id => reservations(:gato_past_plainuser1)
    assert_response :redirect
    assert_redirected_to reservations_path
    assert_match /Reminders cannot be sent once the session has ended./, flash[:alert]

    login_as( users( :admin1 ) )
    get :send_reminder, :id => reservation
    assert_response :redirect
    assert_redirected_to sessions_reservations_path( reservation.session )
    assert_match /A reminder has been sent to/, flash[:notice]

    login_as( users( :editor1 ) )
    get :send_reminder, :id => reservation
    assert_response :redirect
    assert_redirected_to sessions_reservations_path( reservation.session )
    assert_match /A reminder has been sent to/, flash[:notice]

    login_as( users( :instructor1 ) )
    get :send_reminder, :id => reservation
    assert_response :redirect
    assert_redirected_to sessions_reservations_path( reservation.session )
    assert_match /A reminder has been sent to/, flash[:notice]

    login_as( users( :instructor2 ) )
    get :send_reminder, :id => reservation
    assert_response :redirect
    assert_redirected_to root_url
    assert_match /Reminders can only be sent by their owner, an admin, or an instructor/, flash[:alert]

  end

  test "Deleting a reservation just marks it as cancelled" do
    reservation = reservations( :plainuser1 )
    login_as( users( :plainuser1 ) )
    assert_differences [['Reservation.count', +0], ['Reservation.active.count', -1]] do
      delete :destroy, :id => reservation
    end
    reservation.reload
    assert_equal true, reservation.cancelled?
  end

  test "Re-Creating a cancelled reservation uncancells the existing one" do
    reservation = reservations( :plainuser1 )
    reservation.cancel!

    login_as( users( :plainuser1 ) )
    assert_differences [['Reservation.count', +0], ['Reservation.active.count', +1]] do
      get :create, :session_id => sessions( :gato )
    end

    reservation.reload
    assert_equal false, reservation.cancelled?
  end

  test "Deleting a reservation with no waiting list shouldn't trigger any emails" do
    login_as( users( :plainuser1 ) )
    assert_difference 'ActionMailer::Base.deliveries.size', +0 do
      delete :destroy, :id => reservations( :plainuser1 )
    end
  end
  
  test "When a reservation is deleted, the first person in the waiting list should be promoted and get an email" do
    login_as( users( :plainuser1 ) )

    assert_equal 3, sessions( :gato_overbooked ).reservations.size
    assert_equal 1, sessions( :gato_overbooked ).waiting_list.size
    assert_equal 2, sessions( :gato_overbooked ).confirmed_reservations.size
    
    assert_equal users( :plainuser2 ).name, sessions( :gato_overbooked ).confirmed_reservations.first.user.name
    assert_equal users( :plainuser1 ).name, sessions( :gato_overbooked ).confirmed_reservations.last.user.name
    assert_equal users( :plainuser3 ).name, sessions( :gato_overbooked ).waiting_list.first.user.name

    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      delete :destroy, :id => reservations( :overbooked_plainuser1 )
      assert_redirected_to reservations_path
      assert_match "has been cancelled", flash[:notice]
    end

    Reservation.counter_culture_fix_counts
    sessions( :gato_overbooked ).reload
    assert_equal 2, sessions( :gato_overbooked ).reservations.size
    assert_equal 0, sessions( :gato_overbooked ).waiting_list.size
    assert_equal 2, sessions( :gato_overbooked ).confirmed_reservations.size
    
    assert_equal users( :plainuser2 ).name, sessions( :gato_overbooked ).confirmed_reservations.first.user.name
    assert_equal users( :plainuser3 ).name, sessions( :gato_overbooked ).confirmed_reservations.last.user.name
    
    promotion_email = ActionMailer::Base.deliveries.last
    assert_equal "Now Enrolled: " + topics( :gato ).name, promotion_email.subject
    assert_equal users( :plainuser3 ).email, promotion_email.to[0]
    
  end

  test "When a waiting-list reservation is deleted, no emails are sent" do
    login_as( users( :plainuser3 ) )

    assert_equal 3, sessions( :gato_overbooked ).reservations.size
    assert_equal 1, sessions( :gato_overbooked ).waiting_list.size
    assert_equal 2, sessions( :gato_overbooked ).confirmed_reservations.size
    
    assert_equal users( :plainuser2 ).name, sessions( :gato_overbooked ).confirmed_reservations.first.user.name
    assert_equal users( :plainuser1 ).name, sessions( :gato_overbooked ).confirmed_reservations.last.user.name
    assert_equal users( :plainuser3 ).name, sessions( :gato_overbooked ).waiting_list.first.user.name

    assert_difference 'ActionMailer::Base.deliveries.size', 0 do
      delete :destroy, :id => reservations( :overbooked_plainuser3 )
      assert_redirected_to reservations_path
      assert_match "has been cancelled", flash[:notice]
    end

    Reservation.counter_culture_fix_counts
    sessions( :gato_overbooked ).reload
    assert_equal 2, sessions( :gato_overbooked ).reservations.size
    assert_equal 0, sessions( :gato_overbooked ).waiting_list.size
    assert_equal 2, sessions( :gato_overbooked ).confirmed_reservations.size
    
    assert_equal users( :plainuser2 ).name, sessions( :gato_overbooked ).confirmed_reservations.first.user.name
    assert_equal users( :plainuser1 ).name, sessions( :gato_overbooked ).confirmed_reservations.last.user.name
        
  end
  
  test "Show what training sessions user is registered for" do
    login_as( users( :plainuser1 ) )
    get :index
    assert_equal 6,  assigns( :confirmed_reservations ).size, "Number of upcoming sessions for Plainuser1 was incorrect."
    assert_equal 4,  assigns( :past_reservations ).size, "Number of past sessions for Plainuser1 was incorrect."
    assert_equal 0,  assigns( :waiting_list_signups ).size, "Number of wait listed sessions for Plainuser1 was incorrect."
    assert_response :success

    login_as( users( :plainuser2 ) )
    get :index
    assert_equal 3,  assigns( :confirmed_reservations ).size, "Number of upcoming sessions for Plainuser2 was incorrect."
    assert_equal 4,  assigns( :past_reservations ).size, "Number of past sessions for Plainuser2 was incorrect."
    assert_equal 0,  assigns( :waiting_list_signups ).size, "Number of wait listed sessions for Plainuser2 was incorrect."
    assert_response :success
    
    login_as( users( :plainuser3 ) )
    get :index
    assert_equal 2,  assigns( :confirmed_reservations ).size, "Number of upcoming sessions for Plainuser3 was incorrect."
    assert_equal 0,  assigns( :past_reservations ).size, "Number of past sessions for Plainuser3 was incorrect."
    assert_equal 1,  assigns( :waiting_list_signups ).size, "Number of wait listed sessions for Plainuser3 was incorrect."
    assert_response :success
  end
  
  test "Cancelled sessions shouldn't show up on a user's reservation list" do
    login_as( users( :plainuser3 ) )
    get :index
    assert_equal 2,  assigns( :confirmed_reservations ).size, "Number of upcoming sessions for Plainuser3 was incorrect."
    assert_response :success    
  end
  
  test "Try downloading a reservation as ICS" do
    login_as( users( :plainuser1 ) )
    get :show, :id => reservations( :plainuser1 )
    assert_response :redirect
    assert_redirected_to reservations_path
    get :show, :id => reservations( :plainuser1 ), :format => :ics
    assert_response :success
    assert_equal @response.content_type, 'text/calendar'
  end
  
end
