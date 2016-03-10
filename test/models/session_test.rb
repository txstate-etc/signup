require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  fixtures :sessions, :topics, :users

  def setup
    Reservation.counter_culture_fix_counts
  end

  test "Should determine whether space is available correctly" do
    session = Session.find( sessions( :tracs_tiny ).id )
    assert session.space_is_available?

    session = Session.find( sessions( :tracs_tiny_full ).id )
    assert !session.space_is_available?

    session = Session.find( sessions( :gato_huge ).id )
    assert session.space_is_available?    
  end
  
  test "Should distinguish waiting list vs. reservations correctly" do
    session = Session.find( sessions( :gato_overbooked ).id )
    assert_equal 2, session.confirmed_count, "Wrong number of reservations for Gato"
    assert_equal 1, session.waiting_list_count, "Wrong number on waiting list for Gato"
    
    session = Session.find( sessions( :tracs ).id )
    assert_equal 1, session.confirmed_count, "Wrong number of reservations for TRACS"
    assert_equal 0, session.waiting_list_count, "Wrong number on waiting list for TRACS"
    
    session = Session.find( sessions( :gato_cancelled ).id )
    assert_equal 1, session.confirmed_count, "Wrong number of reservations for cancelled class"
    assert_equal 0, session.waiting_list_count, "Wrong number on waiting list for cancelled class"
  end
  
  test "Reservation counts should be updated when reservations are created and destroyed" do
    # FIXME: this test has a bunch of kludginess to get around counter_culture issues
    teardown_fixtures
    Reservation.counter_culture_fix_counts
    self.class.use_transactional_fixtures = false

    session = Session.find( sessions( :gato_overbooked ).id )
    assert_equal 3, session.reservations_count
    reservation = session.reservations.create!(:user => users(:plainuser4))
    session.reload
    assert_equal 4, session.reservations.count, "Res count not updated after reservation creation"
    assert_equal 4, session.reservations_count, "Res count not updated after reservation creation"
    assert_equal 2, session.confirmed_count, "Wrong number of reservations for Gato"
    assert_equal 2, session.waiting_list_count, "Wrong number on waiting list for Gato"

    reservation.cancel!
    session.reload
    assert_equal 1, session.waiting_list_count, "Wrong number on waiting list for Gato"
    assert_equal 3, session.reservations_count, "Res count not updated after reservation deletion"

    reservation.uncancel!
    session.reload
    assert_equal 2, session.waiting_list_count, "Wrong number on waiting list for Gato"
    assert_equal 4, session.reservations_count, "Res count not updated after reservation un-deletion"

    reservation.destroy!

    session = Session.find( sessions( :tracs ).id )
    assert_equal 1, session.reservations_count
    reservation = session.reservations.create!(:user => users(:plainuser4))
    session.reload
    assert_equal 2, session.confirmed_count, "Wrong number of reservations for TRACS"
    assert_equal 0, session.waiting_list_count, "Wrong number on waiting list for TRACS"
    assert_equal 2, session.reservations_count, "Res count not updated after reservation creation"

    reservation.cancel!
    session.reload
    assert_equal 1, session.confirmed_count, "Wrong number of reservations for Gato"
    assert_equal 1, session.reservations_count, "Res count not updated after reservation deletion"

    reservation.uncancel!
    session.reload
    assert_equal 2, session.confirmed_count, "Wrong number of reservations for Gato"
    assert_equal 2, session.reservations_count, "Res count not updated after reservation un-deletion"

    reservation.destroy!
  
    setup_fixtures
    self.class.use_transactional_fixtures = true

  end

  test "Users should be updated when location or time of a class changes" do
    assert_difference 'ActionMailer::Base.deliveries.size', +3 do
      sessions( :gato_overbooked ).location = "The Third Circle of Hell"
      sessions( :gato_overbooked ).save!
    end

    assert_difference 'ActionMailer::Base.deliveries.size', +3 do
      sessions( :gato_overbooked ).occurrences[0].time = Time.now + 1.day
      sessions( :gato_overbooked ).save!
    end

    # Should not send for sessions in the past
    assert_difference 'ActionMailer::Base.deliveries.size', +0 do
      sessions( :gato_overbooked ).occurrences[0].time = Time.now - 1.day
      sessions( :gato_overbooked ).save!
    end
    
    assert_difference 'ActionMailer::Base.deliveries.size', +0 do
      sessions( :gato_overbooked ).instructors << users( :instructor1 )
      sessions( :gato_overbooked ).save!
    end
    
  end
  
  test "Try reminder emails for year 2035" do
    start_date = DateTime.parse( '1 January 2035' )
    end_date = DateTime.parse( '31 December 2035' )
    
    assert_difference 'ActionMailer::Base.deliveries.size', +15 do
      Session.send_reminders( start_date, end_date )
    end
  end

  test "Verify that correct person gets emailed" do
    start_date = DateTime.parse( '15 June 2035 00:00' )
    end_date = DateTime.parse( '15 June 2035 23:59' )
    assert_difference 'ActionMailer::Base.deliveries.size', +2 do
      Session.send_reminders( start_date, end_date )
    end
    
    reminder_email = ActionMailer::Base.deliveries.last
    assert_equal reminder_email.subject, "Reminder: " + topics( :tracs ).name
    assert_equal reminder_email.to[0], users( :instructor2 ).email

    reminder_email = ActionMailer::Base.deliveries[-2]
    assert_equal reminder_email.subject, "Reminder: " + topics( :tracs ).name
    assert_equal reminder_email.to[0], users( :plainuser3 ).email
  end
  
  test "Sessions with automatic or external surveys should get emails, but only for folks not marked as absent" do
    assert_difference 'ActionMailer::Base.deliveries.size', +8 do
      assert_difference 'Session.where(survey_sent: false).count', -6 do
        Session.send_followups
      end
    end

    ActionMailer::Base.deliveries.last(8).each do |survey_email|
      assert_match 'localhost', survey_email.text_part.body.to_s, "URLs not being constructed properly"
      if (survey_email.to & [:plainuser1, :plainuser2, :plainuser3].map { |u| users(u).email }).any?
        assert_match /\/survey_responses\/new\?reservation_id=#{reservations(:multi_time_topic_completed_plainuser2).id}|http:\/\/localhost\/tracssurvey/, survey_email.text_part.body.to_s, "URLs not being constructed properly"
      end
    end
  end
  
  test "Should compute seats remaining correctly" do
    assert_equal 0, sessions( :gato_overbooked ).seats_remaining
    assert_equal 1, sessions( :tracs_tiny ).seats_remaining
    assert_equal 0, sessions( :tracs_tiny_full ).seats_remaining
    assert_equal nil, sessions( :gato_huge ).seats_remaining
    assert_equal 17, sessions( :gato ).seats_remaining
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

    assert test_session.update( { :instructors_attributes => {
      "1305227580344" => {"name_and_login"=>"Instructor2 (i23456)", "_destroy"=>""},
                  "0" => {"name_and_login"=>"Instructor1 (i12345)", "id"=> users( :instructor1 ).id, "_destroy"=>"1"}
    }})
      
    assert_equal 1, test_session.instructors.size
    assert_equal users( :instructor2 ), test_session.instructors[0]
    
    assert test_session.update( { :instructors_attributes => {
      "0" => {"name_and_login"=>"Instructor1 (i12345)", "id"=> users( :instructor2 ).id,"_destroy"=>""}
    }})
    assert_equal 1, test_session.instructors.size
    assert_equal users( :instructor1 ), test_session.instructors[0]

    test_session2 = Session.new( { 
      :occurrences_attributes =>{"0"=>{"time"=>"May 25, 2015 12:00 PM", "_destroy"=>""}}, 
      :location => "Alkek 155", 
      :site_id => sites( :sanmarcos ).id,
      :topic_id => topics( :gato ).id,
      :instructors_attributes => {
        "0" => {"name_and_login"=>"Instructor2 (i23456)", "_destroy"=>""},
        "1305227580344" => {"name_and_login"=>"Instructor1 (i12345)", "_destroy"=>""}
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
    test_session.site = sites( :sanmarcos )
    test_session.instructor_ids = [ users( :instructor2 ).id ]
    assert test_session.save
  end

  test "Session with an invalid instructor is not valid" do
    test_session = Session.new( { 
      :occurrences_attributes =>{"0"=>{"time"=>"May 25, 2015 12:00 PM", "_destroy"=>""}}, 
      :location => "Alkek 155", 
      :site_id => sites( :sanmarcos ).id,
      :topic_id => topics( :gato ).id,
      :instructors_attributes => {
        "0" => {"name_and_login"=>"Fake Instructor (notreal)", "_destroy"=>""},
        "1305227580344" => {"name_and_login"=>"Instructor1 (i12345)", "_destroy"=>""}
      }
    })  
    assert !test_session.save
  end

  test "Session with no occurrences is not valid" do
    test_session = Session.new
    test_session.topic = topics( :gato )
    #test_session.occurrences.build(:time => DateTime.parse( '15 June 2035 00:00' ))
    test_session.location = "Tijuana"
    test_session.site = sites( :sanmarcos )
    test_session.instructor_ids = [ users( :instructor2 ).id ]
    assert !test_session.save 

    test_session = sessions( :gato )
    assert !test_session.update( { :occurrences_attributes => {
      "0" => {"time"=>test_session.occurrences.first.time, "id"=> test_session.occurrences.first.id,"_destroy"=>"1"}
    }})
  end

  test "Session with no topic is not valid" do
    test_session = Session.new
    #test_session.topic = topics( :gato )
    test_session.occurrences.build(:time => DateTime.parse( '15 June 2035 00:00' ))
    test_session.location = "Tijuana"
    test_session.site = sites( :sanmarcos )
    test_session.instructor_ids = [ users( :instructor2 ).id ]
    assert !test_session.save 

  end
 
  test "Session with no location is not valid" do
    test_session = Session.new
    test_session.topic = topics( :gato )
    test_session.occurrences.build(:time => DateTime.parse( '15 June 2035 00:00' ))
    #test_session.location = "Tijuana"
    test_session.site = sites( :sanmarcos )
    test_session.instructor_ids = [ users( :instructor2 ).id ]
    assert !test_session.save 

    test_session = sessions( :gato )
    assert !test_session.update( { :location => ""})
  end

  test "Session with no site is not valid" do
    test_session = Session.new
    test_session.topic = topics( :gato )
    test_session.occurrences.build(:time => DateTime.parse( '15 June 2035 00:00' ))
    test_session.location = "Tijuana"
    #test_session.site = sites( :sanmarcos )
    test_session.instructor_ids = [ users( :instructor2 ).id ]
    assert !test_session.save 
  end

  test "Seats must be integer or null" do
    test_session = Session.new
    test_session.topic = topics( :gato )
    test_session.occurrences.build(:time => DateTime.parse( '15 June 2035 00:00' ))
    test_session.location = "Tijuana"
    test_session.site = sites( :sanmarcos )
    test_session.instructor_ids = [ users( :instructor2 ).id ]
    test_session.seats = 'foo'
    assert !test_session.save 

    test_session.seats = 3.14
    assert !test_session.save 

    test_session.seats = 99
    assert test_session.save 

    test_session = sessions( :gato )
    assert !test_session.update( { :seats => "1.21"})

    test_session = sessions( :gato )
    assert test_session.update( { :seats => ""})
  end

  test "Seats must be not be fewer than confirmed_reservations" do
    test_session = sessions( :gato )
    assert_equal 3, test_session.confirmed_reservations.count
    new_seats = test_session.confirmed_reservations.count - 1
    assert !test_session.update( { :seats => "#{new_seats}"})
  end

  test "Registration times must be sane" do
    test_session = sessions( :gato )
    assert test_session.valid?

    test_session.reg_start = test_session.time + 1.minute
    assert !test_session.valid?

    test_session.reg_start = test_session.time - 1.month
    assert test_session.valid?

    test_session.reg_start = test_session.time - 1.month
    test_session.reg_end = test_session.time + 1.minute
    assert !test_session.valid?

    test_session.reg_start = test_session.time - 1.month
    test_session.reg_end = test_session.time - 2.months
    assert !test_session.valid?
 
    test_session.reg_start = test_session.time - 1.month
    test_session.reg_end = test_session.time - 1.minute
    assert test_session.valid?

  end

  test "We should be able to determine who is an instructor" do
    test_session = sessions( :gato )
    assert test_session.instructor?( users( :instructor1 ) )
    assert !test_session.instructor?( users( :instructor2 ) )
  end
  
  test "Confirmed Reservations should be alphabetized by last name" do
    test_session = sessions( :gato_overbooked )
    assert_equal 2, sessions( :gato_overbooked ).confirmed_reservations.size
    assert_equal users( :plainuser2 ).name, test_session.confirmed_reservations.first.user.name
    assert_equal users( :plainuser1 ).name, test_session.confirmed_reservations.last.user.name
    assert_equal users( :plainuser1 ).name, test_session.confirmed_reservations_by_last_name.first.user.name
    assert_equal users( :plainuser2 ).name, test_session.confirmed_reservations_by_last_name.last.user.name
    assert_equal test_session.confirmed_reservations_by_last_name, test_session.confirmed_reservations.sort { |a,b| a.user.last_name <=> b.user.last_name }
  end
  
  test "Try reminder emails for a multi time session" do
    assert_equal 2, sessions( :multi_time_topic ).occurrences.count
    
    # it should send one reminder (for recipient and instructor) for the first occurrence
    start_date = DateTime.parse( '7 May 2045' ).at_beginning_of_day
    end_date = DateTime.parse( '7 May 2045' ).end_of_day    
    assert_difference 'ActionMailer::Base.deliveries.size', +2 do
      Session.send_reminders( start_date, end_date )
    end

    # it should send no reminders if there are no occurrences for the day
    start_date = DateTime.parse( '8 May 2045' ).at_beginning_of_day
    end_date = DateTime.parse( '8 May 2045' ).end_of_day    
    assert_difference 'ActionMailer::Base.deliveries.size', 0 do
      Session.send_reminders( start_date, end_date )
    end

    # it should still send reminders for the second occurrence
    start_date = DateTime.parse( '9 May 2045' ).at_beginning_of_day
    end_date = DateTime.parse( '9 May 2045' ).end_of_day    
    assert_difference 'ActionMailer::Base.deliveries.size', +4 do
      Session.send_reminders( start_date, end_date )
    end
    
    # it should NOT send reminders for the second occurrence if only_first_occurrence is true (3rd param to send_reminders)
    start_date = DateTime.parse( '9 May 2045' ).at_beginning_of_day
    end_date = DateTime.parse( '9 May 2045' ).end_of_day    
    assert_difference 'ActionMailer::Base.deliveries.size', 0 do
      Session.send_reminders( start_date, end_date, true )
    end
  end
  
  test "ics for multi time sessions has multiple events" do
    assert_equal 2, RiCal.parse_string(sessions( :multi_time_topic ).to_cal).first.events.size
  end
  
  test "emails sent to reservations after cancellation" do
    assert_difference 'ActionMailer::Base.deliveries.size', +3 do
      sessions( :gato_overbooked ).cancel!
    end

    cancellation_emails = ActionMailer::Base.deliveries.last(3)
    cancellation_emails.each do |email|
      assert_equal "Class Cancelled: " + topics( :gato ).name, email.subject
    end    
    assert_equal users( :instructor1 ).email, cancellation_emails[0].to[0]
    assert_equal users( :plainuser2 ).email, cancellation_emails[1].to[0]
    assert_equal users( :plainuser1 ).email, cancellation_emails[2].to[0]
  
    # no emails for sessions in the past
    assert_difference 'ActionMailer::Base.deliveries.size', +0 do
      sessions( :gato_past ).cancel!
    end
  end

  test "emails sent to instructors after cancellation" do
    assert_difference 'ActionMailer::Base.deliveries.size', +3 do
      sessions( :tracs_multiple_instructors ).cancel!
    end

    cancellation_emails = ActionMailer::Base.deliveries.last(3)
    cancellation_emails.each do |email|
      assert_equal "Class Cancelled: " + topics( :tracs ).name, email.subject
    end    
    assert_equal users( :instructor1 ).email, cancellation_emails[0].to[0]
    assert_equal users( :instructor2 ).email, cancellation_emails[1].to[0]
    assert_equal users( :plainuser1 ).email, cancellation_emails[2].to[0]
  end
  
  
end
