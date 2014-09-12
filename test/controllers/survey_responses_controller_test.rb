require 'test_helper'

class SurveyResponsesControllerTest < ActionController::TestCase
  fixtures :users, :reservations
  
  test "The user who made a reservation should be able to submit feedback once" do
    login_as( users( :plainuser3 ) )
    
    get :new, :reservation_id => reservations( :gato_past_plainuser3 ).id
    assert_response :success

    assert_difference 'SurveyResponse.all.size', +1 do
      post :create, :reservation_id => reservations( :gato_past_plainuser3 ).id, :survey_response => { :reservation_id => reservations( :gato_past_plainuser3 ).id, :class_rating => 2, :instructor_rating =>2, :applicability => 2 }
    end
    assert_response :redirect

    assert_difference 'SurveyResponse.all.size', +0 do
      post :create, :reservation_id => reservations( :gato_past_plainuser3 ).id, :survey_response => { :reservation_id => reservations( :gato_past_plainuser3 ).id, :class_rating => 2, :instructor_rating =>2, :applicability => 2 }
    end
    assert_response :success

  end
  
  test "Users shouldn't be able to submit feedback on sessions that haven't yet happened" do
    login_as( users( :plainuser3 ) )

    assert_difference 'SurveyResponse.all.size', +0 do
      post :create, :reservation_id => reservations( :plainuser3 ).id, :survey_response => { :reservation_id => reservations( :plainuser3 ).id, :class_rating => 2, :instructor_rating =>2, :applicability => 2 }
    end
    assert_response :success
  end
  
  test "Users shouldn't be able to submit feedback on sessions that haven't yet completed" do
    login_as( users( :plainuser1 ) )

    assert_difference 'SurveyResponse.all.size', +0 do
      post :create, :reservation_id => reservations( :multi_time_topic_started_plainuser1 ).id, :survey_response => { :reservation_id => reservations( :multi_time_topic_started_plainuser1 ).id, :class_rating => 2, :instructor_rating =>2, :applicability => 2 }
    end
    assert_response :success
  end
  
  test "Users shouldn't be able to submit feedback on sessions that have been cancelled" do
    login_as( users( :plainuser3 ) )

    assert_difference 'SurveyResponse.all.size', +0 do
      post :create, :reservation_id => reservations(  :gato_cancelled_plainuser3 ).id, :survey_response => { :reservation_id => reservations(  :gato_cancelled_plainuser3 ).id, :class_rating => 2, :instructor_rating =>2, :applicability => 2 }
    end
    assert_response :success    
  end
  
  test "Other users shouldn't be able to submit feedback linked to a reservation" do
    login_as( users( :plainuser1 ) )

    assert_difference 'SurveyResponse.all.size', +0 do
      post :create, :reservation_id => reservations( :gato_past_plainuser3 ).id, :survey_response => { :reservation_id => reservations( :gato_past_plainuser3 ).id, :class_rating => 2, :instructor_rating =>2, :applicability => 2 }
    end
    assert_response :redirect
    
  end
end
