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
    assert_equal 0, session.confirmed_reservations.size, "Wrong number of reservations for cancelled class"
    assert_equal 0, session.waiting_list.size, "Wrong number on waiting list for cancelled class"
  end
  
  test "Try reminder emails for year 2035" do
    start_date = DateTime.parse( '1 January 2035' )
    end_date = DateTime.parse( '31 December 2035' )
    
    assert_difference 'ActionMailer::Base.deliveries.size', +5 do
      Session.send_reminders( start_date, end_date )
    end
  end

  test "Verify that correct person gets emailed" do
    start_date = DateTime.parse( '15 June 2035 00:00' )
    end_date = DateTime.parse( '15 June 2035 23:59' )
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      Session.send_reminders( start_date, end_date )
    end
    
    reminder_email = ActionMailer::Base.deliveries.last
    assert_equal reminder_email.subject, "Reminder: " + topics( :tracs ).name
    assert_equal reminder_email.to[0], users( :plainuser3 ).email
  end

end
