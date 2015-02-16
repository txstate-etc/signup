require 'test_helper'

class ReservationTest < ActiveSupport::TestCase
  fixtures :topics, :reservations, :users
  
  def setup
    Reservation.counter_culture_fix_counts
  end

  # We prevent this at the controller level, but not at the model level because
  # admins can make reservations for walkins after the class is over,
  # and the model has no knowledge of who is logged on.
  test "Should be able to make reservations for sessions in the past" do
    reservation = Reservation.new( :session => sessions( :gato_past ), :user => users( :plainuser4 ) )
    assert reservation.save
  end

  # We prevent this at the controller level, but not at the model level because
  # admins can make reservations for walkins after the class is over,
  # and the model has no knowledge of who is logged on.
  test "Should be able to make reservations for sessions that have started" do
    reservation = Reservation.new( :session => sessions( :multi_time_topic_started ), :user => users( :plainuser2 ) )
    assert reservation.save
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
    Reservation.counter_culture_fix_counts
    sessions( :tracs_tiny ).reload

    assert_equal 1, sessions( :tracs_tiny ).confirmed_reservations.size
    assert_equal 1, sessions( :tracs_tiny ).waiting_list.size
  end
  
  test "The same person shouldn't be able to register for a class more than once" do
    reservation = Reservation.new( :session => sessions( :gato_huge ),  :user => users( :plainuser2 ) )
    assert reservation.save, reservation.errors.full_messages.to_s
    reservation = Reservation.new( :session => sessions( :gato_huge ),  :user => users( :plainuser2 ) )
    assert !reservation.save    
  end
  
  test "Should be able to make a reservation for an otherwise valid class" do 
    reservation = Reservation.new( :session => sessions( :gato_huge ),  :user => users( :plainuser2 ) )
    assert reservation.save, reservation.errors.full_messages.to_s
  end
  
  test "Make sure confirmed? works correctly" do
    assert reservations( :overbooked_plainuser1 ).confirmed?
    assert reservations( :overbooked_plainuser2 ).confirmed?
    assert reservations( :overbooked_plainuser3 ).on_waiting_list?
    
    # make sure everyone's confirmed in sessions without seat limits
    assert reservations( :gato_huge_plainuser1 ).confirmed?
    assert !reservations( :gato_huge_plainuser1 ).on_waiting_list?
  end
  
  test "Promoted reservations get emails" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      reservations( :overbooked_plainuser1 ).cancel!
    end

    # No emails sent if session is in past
    session = sessions( :gato_past )
    reservation = Reservation.new( :session => session, :user => users( :plainuser4 ) )
    assert reservation.save
    Reservation.counter_culture_fix_counts
    session.reload
    assert_equal users( :plainuser4 ), session.waiting_list.last.user
    assert_equal 1, session.waiting_list.size
    assert_equal 4, session.reservations.size
    assert_equal 3, session.confirmed_reservations.size
    assert_difference 'ActionMailer::Base.deliveries.size', +0 do
       reservation = reservations( :gato_past_plainuser1 )
       reservation.cancel!
    end
    Reservation.counter_culture_fix_counts
    session.reload
    assert_equal 3, session.reservations.size
    assert_equal 3, session.confirmed_reservations.size
    assert_equal 0, session.waiting_list.size
    assert_equal users( :plainuser4 ), session.confirmed_reservations.last.user

  end

  test "Instructor should receive email if special accomodations are needed" do
    reservation = Reservation.new( :session => sessions( :tracs_multiple_instructors ),  :user => users( :plainuser2 ) )
    reservation.save
    reservation.reload
    assert_equal nil, reservation.special_accommodations
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      reservation.special_accommodations = "I'd like an eggplant"
      reservation.save!
    end
    reservation.reload
    assert_equal "I'd like an eggplant", reservation.special_accommodations
    assert_equal ActionMailer::Base.deliveries.last.to.size, 2
    assert_equal ActionMailer::Base.deliveries.last.to[0], sessions( :tracs_multiple_instructors ).instructors[0].email
    assert_equal ActionMailer::Base.deliveries.last.to[1], sessions( :tracs_multiple_instructors ).instructors[1].email

    # send emails when ading accommodations later as well
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      reservation.special_accommodations = "I'd like 2 eggplants"
      reservation.save!
    end

    # send emails when ading accommodations later as well
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      reservation = reservations( :plainuser1 )
      reservation.special_accommodations = "I'd like 3 eggplants"
      reservation.save!
    end

    # no emails for sessions in the past
    assert_difference 'ActionMailer::Base.deliveries.size', +0 do
      reservation = reservations( :gato_past_plainuser1 )
      reservation.special_accommodations = "I'd like an eggplant"
      reservation.save!
    end
  end

  test "Cancelled reservations should not be deleted" do
    reservation = reservations( :overbooked_plainuser1 )
    res_id = reservation.id
    assert_equal reservation, Reservation.find(res_id), "Cancelling does not remove the object"
    assert_equal false, reservation.cancelled?
    assert_equal true, reservation.confirmed?
    assert_equal false, reservation.on_waiting_list?
    assert_equal true, reservation.session.reservations.include?(reservation)

    assert_differences [['Reservation.count', +0], ['Reservation.active.count', -1]] do
      assert reservation.cancel!, "Cancelling should return true"
    end

    reservation.reload
    assert_equal reservation, Reservation.find(res_id), "Cancelling does not remove the object"
    assert_equal true, reservation.cancelled?
    assert_equal false, reservation.confirmed?
    assert_equal false, reservation.on_waiting_list?
    assert_equal false, reservation.session.reservations.include?(reservation)
  end

  test "UnCancelled reservations should not reuse same object" do
    reservation = reservations( :overbooked_plainuser1 )
    res_id = reservation.id
    reservation.cancel!
    reservation.reload
    assert_equal true, reservation.cancelled?
    
    assert_differences [['Reservation.count', +0], ['Reservation.active.count', +1]] do
      assert reservation.uncancel!, "Cancelling should return true"
    end

    reservation.reload
    assert_equal reservation, Reservation.find(res_id), "UnCancelling does not create a new object"
    assert_equal false, reservation.cancelled?
    assert_equal true, reservation.session.reservations.include?(reservation)
  end

  test "UnCancelled reservations should go to the end of the line" do
    # Sanity check to make sure the reservations are ordered the way we think
    # The session has 2 seats, so the 3rd reservation is on the waiting list.
    # The created_ats are ordered 2,1,3
    reservations = [
      reservations( :overbooked_plainuser2 ),
      reservations( :overbooked_plainuser1 ),
      reservations( :overbooked_plainuser3 ) 
    ]
    session = sessions(:gato_overbooked)
    assert_equal reservations, session.reservations.to_a
    assert_equal reservations[0..1], session.confirmed_reservations.to_a
    assert_equal reservations[2], session.waiting_list[0]

    # We have to update the created_ats here because the ones
    # defined in the fixtures are far in the future.
    time = Time.now - 6.minutes 
    reservations.each do |r|
      r.created_at = time
      r.save
      r.reload
      time += 1.minute
    end

    # Now we'll cancel the first reservation and make sure
    # he is removed from the list
    reservation = reservations[0]
    created_at = reservation.created_at
    reservation.cancel!
    reservation.reload
    session.reload
    assert_equal true, reservation.cancelled?

    reservations = [
      reservations( :overbooked_plainuser1 ),
      reservations( :overbooked_plainuser3 ),
      reservations( :overbooked_plainuser2 ) 
    ]
    assert_equal reservations[0..1], session.reservations.to_a

    # Now, we'll uncancel the same reservation and make sure
    # he is added back to the end of the list.
    reservation.uncancel!
    Reservation.counter_culture_fix_counts
    session.reload
    reservation.reload
    assert_equal false, reservation.cancelled?
    assert_not_equal created_at, reservation.created_at, "created_at should have been updated when UnCancelled"
    assert_equal reservations, session.reservations.to_a
    assert_equal false, reservation.confirmed?
    assert_equal true, reservation.on_waiting_list?
    assert_equal reservations[0..1], session.confirmed_reservations.to_a
    assert_equal reservations[2], session.waiting_list[0]

  end

end
