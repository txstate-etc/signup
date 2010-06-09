require 'test_helper'

class ReservationTest < ActiveSupport::TestCase
  fixtures :topics, :reservations, :admins
  
  test "Shouldn't be able to make reservations for sessions in the past" do
    reservation = Reservation.new( :session => sessions( :gato_past ), :login => "testuser", :name => "Test User" )
    assert !reservation.save
  end
  
  test "Shouldn't be able to make reservations for sessions that have been cancelled" do
    reservation = Reservation.new( :session => sessions( :gato_cancelled ), :login => "testuser", :name => "Test User" )
    assert !reservation.save
  end
  
  test "Shouldn't be able to make a reservation if the class is already filled up" do
    reservation = Reservation.new( :session => sessions( :tracs_tiny ), :login => "testuser", :name => "Test User" )
    assert reservation.save
    reservation = Reservation.new( :session => sessions( :tracs_tiny ), :login => "otheruser", :name => "Other User" )
    assert !reservation.save    
  end
  
  test "The same person shouldn't be able to register for a class more than once" do
    reservation = Reservation.new( :session => sessions( :gato ), :login => "testuser", :name => "Test User" )
    assert reservation.save
    reservation = Reservation.new( :session => sessions( :gato ), :login => "testuser", :name => "Test User" )
    assert !reservation.save    
  end
  
  test "Should be able to make a reservation for an otherwise valid class" do 
    reservation = Reservation.new( :session => sessions( :gato ), :login => "testuser", :name => "Test User" )
    assert reservation.save
  end
end
