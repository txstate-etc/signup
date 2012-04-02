require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  fixtures :sessions, :topics, :users
  test "Should determine whether space is available correctly" do
    session = Session.find( sessions( :tracs_tiny ) )
    assert session.space_is_available?

    session = Session.find( sessions( :tracs_tiny_full ) )
    assert !session.space_is_available?

    session = Session.find( sessions( :gato_huge ) )
    assert session.space_is_available?    
  end
  
  test "Should distinguish waiting list vs. reservations correctly" do
    session = Session.find( sessions( :gato_overbooked ) )
    assert_equal 2, session.confirmed_reservations.size, "Wrong number of reservations for Gato"
    assert_equal 1, session.waiting_list.size, "Wrong number on waiting list for Gato"
    
    session = Session.find( sessions( :tracs ) )
    assert_equal 1, session.confirmed_reservations.size, "Wrong number of reservations for TRACS"
    assert_equal 0, session.waiting_list.size, "Wrong number on waiting list for TRACS"
    
    session = Session.find( sessions( :gato_cancelled ) )
    assert_equal 1, session.confirmed_reservations.size, "Wrong number of reservations for cancelled class"
    assert_equal 0, session.waiting_list.size, "Wrong number on waiting list for cancelled class"
  end
  
  test "Users should be updated when location or time of a class changes" do
    assert_difference 'ActionMailer::Base.deliveries.size', +2 do
      sessions( :gato_overbooked ).location = "The Third Circle of Hell"
      sessions( :gato_overbooked ).save
      Delayed::Worker.new(:quiet => true).work_off
    end

    assert_difference 'ActionMailer::Base.deliveries.size', +2 do
      sessions( :gato_overbooked ).occurrences[0].time = Time.now()
      sessions( :gato_overbooked ).save
      Delayed::Worker.new(:quiet => true).work_off
    end
    
    assert_difference 'ActionMailer::Base.deliveries.size', +0 do
      sessions( :gato_overbooked ).instructors << users( :instructor1 )
      sessions( :gato_overbooked ).save
      Delayed::Worker.new(:quiet => true).work_off
    end
    
  end
  
  test "Try reminder emails for year 2035" do
    start_date = DateTime.parse( '1 January 2035' )
    end_date = DateTime.parse( '31 December 2035' )
    
    assert_difference 'ActionMailer::Base.deliveries.size', +13 do
      Session.send_reminders( start_date, end_date )
      Delayed::Worker.new(:quiet => true).work_off
    end
  end

  test "Verify that correct person gets emailed" do
    start_date = DateTime.parse( '15 June 2035 00:00' )
    end_date = DateTime.parse( '15 June 2035 23:59' )
    assert_difference 'ActionMailer::Base.deliveries.size', +2 do
      Session.send_reminders( start_date, end_date )
      Delayed::Worker.new(:quiet => true).work_off
    end
    
    reminder_email = ActionMailer::Base.deliveries.last
    assert_equal reminder_email.subject, "Reminder: " + topics( :tracs ).name
    assert_equal reminder_email.to[0], users( :instructor2 ).email

    reminder_email = ActionMailer::Base.deliveries[-2]
    assert_equal reminder_email.subject, "Reminder: " + topics( :tracs ).name
    assert_equal reminder_email.to[0], users( :plainuser3 ).email
  end
  
  test "Sessions with automatic or external surveys should get emails, but only for folks not marked as absent" do
    assert_difference 'ActionMailer::Base.deliveries.size', +2 do
      assert_difference 'Session.all(:conditions => ["survey_sent = ?", false]).size', -3 do
        Session.send_surveys
        Delayed::Worker.new(:quiet => true).work_off
      end
    end

    ActionMailer::Base.deliveries.last(2).each do |survey_email|
      assert_match 'localhost', survey_email.body, "URLs not being constructed properly"
      assert_match /\/survey_responses\/new\?reservation_id=#{reservations(:multi_time_topic_completed_plainuser2).id}|http:\/\/localhost\/tracssurvey/, survey_email.body, "URLs not being constructed properly"
    end
  end
  
  test "Should compute seats remaining correctly" do
    assert_equal 0, sessions( :gato_overbooked ).seats_remaining
    assert_equal 1, sessions( :tracs_tiny ).seats_remaining
    assert_equal 0, sessions( :tracs_tiny_full ).seats_remaining
    assert_equal nil, sessions( :gato_huge ).seats_remaining
    assert_equal 19, sessions( :gato ).seats_remaining
    assert_equal 20, sessions( :gato_2 ).seats_remaining
  end
  
  test "Should find survey responses correctly" do
    assert_equal 2, sessions( :gato_past ).survey_responses.size
    assert_equal 0, sessions( :gato ).survey_responses.size
  end
  
  test "Should compute average ratings correctly" do
    assert_equal 3.0, topics( :gato ).average_rating
    assert_equal 3.0, topics( :gato ).average_instructor_rating
  end
  
  test "ICS version should include URL if present" do
    assert_match topics( :gato ).url, sessions( :gato ).to_cal.to_s
  end
  
  test "We should be able to use instructor names as well as instructor objects" do
    test_session = sessions( :gato )

    assert test_session.update_attributes( { :instructors_attributes => {
      "1305227580344" => {"name_and_login"=>"Instructor2 (i23456)", "_destroy"=>""},
                  "0" => {"name_and_login"=>"Instructor1 (i12345)", "id"=> users( :instructor1 ).id, "_destroy"=>"1"}
    }})
      
    assert_equal 1, test_session.instructors.size
    assert_equal users( :instructor2 ), test_session.instructors[0]
    
    assert test_session.update_attributes( { :instructors_attributes => {
      "0" => {"name_and_login"=>"Instructor1 (i12345)", "id"=> users( :instructor2 ).id,"_destroy"=>""}
    }})
    assert_equal 1, test_session.instructors.size
    assert_equal users( :instructor1 ), test_session.instructors[0]

    test_session2 = Session.new( { 
      :occurrences_attributes =>{"0"=>{"time"=>"May 25, 2015 12:00 PM", "_destroy"=>""}}, 
      :location => "Alkek 155", 
      :topic_id => topics( :gato ).id,
      :instructors_attributes => {
        "1305227580344" => {"name_and_login"=>"Instructor2 (i23456)", "_destroy"=>""},
                    "0" => {"name_and_login"=>"Instructor1 (i12345)", "_destroy"=>""}
      }
    })       
     
    assert test_session2.save  
    assert_equal 2, test_session2.instructors.size
    assert_equal users( :instructor2 ), test_session2.instructors[0]
    assert_equal users( :instructor1 ), test_session2.instructors[1]

  end
  
  test "We should be able to have multiple instructors" do
    test_session = sessions( :gato )
    test_session.instructors << users( :instructor2 )
    assert_equal 2, test_session.instructors.size
    test_session.instructor_ids = [ users( :instructor2 ).id ]
    assert_equal 1, test_session.instructors.size
  end
  
  test "Session with no instructor is not valid" do
    test_session = Session.new
    test_session.topic = topics( :gato )
    test_session.occurrences.build(:time => DateTime.parse( '15 June 2035 00:00' ))
    test_session.location = "Tijuana"
    assert !test_session.save
  end
  
  test "Session with an instructor is valid" do
    test_session = Session.new
    test_session.topic = topics( :gato )
    test_session.occurrences.build(:time => DateTime.parse( '15 June 2035 00:00' ))
    test_session.location = "Tijuana"
    test_session.instructor_ids = [ users( :instructor2 ).id ]
    assert test_session.save
  end

  test "We should be able to determine who is an instructor" do
    test_session = sessions( :gato )
    assert test_session.instructor?( users( :instructor1 ) )
    assert !test_session.instructor?( users( :instructor2 ) )
  end
  
  test "Confirmed Reservations should be alphabetized by last name" do
    test_session = sessions( :gato_overbooked )
    assert_equal test_session.confirmed_reservations, test_session.confirmed_reservations.sort { |a,b| a.user.last_name <=> b.user.last_name }
  end
  
  test "Try reminder emails for a multi time session" do
    assert_equal 2, sessions( :multi_time_topic ).occurrences.count
    
    # it should send one reminder (for recipient and instructor) for the first occurrence
    start_date = DateTime.parse( '7 May 2045' ).at_beginning_of_day
    end_date = DateTime.parse( '7 May 2045' ).end_of_day    
    assert_difference 'ActionMailer::Base.deliveries.size', +2 do
      Session.send_reminders( start_date, end_date )
      Delayed::Worker.new(:quiet => true).work_off
    end

    # it should send no reminders if there are no occurrences for the day
    start_date = DateTime.parse( '8 May 2045' ).at_beginning_of_day
    end_date = DateTime.parse( '8 May 2045' ).end_of_day    
    assert_difference 'ActionMailer::Base.deliveries.size', 0 do
      Session.send_reminders( start_date, end_date )
      Delayed::Worker.new(:quiet => true).work_off
    end

    # it should still send reminders for the second occurrence
    start_date = DateTime.parse( '9 May 2045' ).at_beginning_of_day
    end_date = DateTime.parse( '9 May 2045' ).end_of_day    
    assert_difference 'ActionMailer::Base.deliveries.size', +4 do
      Session.send_reminders( start_date, end_date )
      Delayed::Worker.new(:quiet => true).work_off
    end
    
    # it should NOT send reminders for the second occurrence if only_first_occurrence is true (3rd param to send_reminders)
    start_date = DateTime.parse( '9 May 2045' ).at_beginning_of_day
    end_date = DateTime.parse( '9 May 2045' ).end_of_day    
    assert_difference 'ActionMailer::Base.deliveries.size', 0 do
      Session.send_reminders( start_date, end_date, true )
      Delayed::Worker.new(:quiet => true).work_off
    end
  end
  
  test "ics for multi time sessions has multiple events" do
    assert_equal 2, RiCal.parse_string(sessions( :multi_time_topic ).to_cal).first.events.size
  end
end
