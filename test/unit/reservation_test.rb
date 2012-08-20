require 'test_helper'

class ReservationTest < ActiveSupport::TestCase
  fixtures :topics, :reservations, :users
  
  test "Shouldn't be able to make reservations for sessions in the past" do
    reservation = Reservation.new( :session => sessions( :gato_past ), :user => users( :plainuser1 ) )
    assert !reservation.save
  end

  test "Shouldn't be able to make reservations for sessions that have started" do
    reservation = Reservation.new( :session => sessions( :multi_time_topic_started ), :user => users( :plainuser2 ) )
    assert !reservation.save
  end
  
  test "Shouldn't be able to make reservations for sessions that have been cancelled" do
    reservation = Reservation.new( :session => sessions( :gato_cancelled ),  :user => users( :plainuser1 ) )
    assert !reservation.save
  end
  
  test "Should go on waiting list if the class is already filled up" do
    reservation = Reservation.new( :session => sessions( :tracs_tiny ),  :user => users( :plainuser1 ) )
    assert reservation.save
    reservation = Reservation.new( :session => sessions( :tracs_tiny ),  :user => users( :plainuser2 ) )
    assert reservation.save  
    
    assert_equal 1, sessions( :tracs_tiny ).confirmed_reservations.size
    assert_equal 1, sessions( :tracs_tiny ).waiting_list.size
  end
  
  test "The same person shouldn't be able to register for a class more than once" do
    reservation = Reservation.new( :session => sessions( :gato ),  :user => users( :plainuser2 ) )
    assert reservation.save, reservation.errors.to_s
    reservation = Reservation.new( :session => sessions( :gato ),  :user => users( :plainuser2 ) )
    assert !reservation.save    
  end
  
  test "Should be able to make a reservation for an otherwise valid class" do 
    reservation = Reservation.new( :session => sessions( :gato ),  :user => users( :plainuser2 ) )
    assert reservation.save, reservation.errors.to_s
  end
  
  test "Make sure confirmed? works correctly" do
    assert reservations( :overbooked_plainuser1 ).confirmed?
    assert reservations( :overbooked_plainuser2 ).confirmed?
    assert reservations( :overbooked_plainuser3 ).on_waiting_list?
    
    # make sure everyone's confirmed in sessions without seat limits
    assert reservations( :gato_huge_plainuser1 ).confirmed?
    assert !reservations( :gato_huge_plainuser1 ).on_waiting_list?
  end
  
  test "Instructor should receive email if special accomodations are needed" do
    reservation = Reservation.new( :session => sessions( :tracs_multiple_instructors ),  :user => users( :plainuser2 ) )
    reservation.save
    reservation.reload
    assert_equal nil, reservation.special_accommodations
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      reservation.special_accommodations = "I'd like an eggplant"
      reservation.save
      Delayed::Worker.new(:quiet => true).work_off
    end
    reservation.reload
    assert_equal "I'd like an eggplant", reservation.special_accommodations
    assert_equal ActionMailer::Base.deliveries.last.to.size, 2
    assert_equal ActionMailer::Base.deliveries.last.to[0], sessions( :tracs_multiple_instructors ).instructors[0].email
    assert_equal ActionMailer::Base.deliveries.last.to[1], sessions( :tracs_multiple_instructors ).instructors[1].email
  end
end
