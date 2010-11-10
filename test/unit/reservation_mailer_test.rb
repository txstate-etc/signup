require 'test_helper'

class ReservationMailerTest < ActionMailer::TestCase
  fixtures :reservations
  
  test "confirm" do
    @expected.subject = 'Reservation Confirmation For: Plain User1'
    @expected.body    = read_fixture('confirm')
    @expected.date    = Time.now
    @expected.from    = 'nobody@txstate.edu'
    @expected.to      = 'pu12345@dev.nul'

    actual = ReservationMailer.create_confirm( reservations( :plainuser1 ) )
    
    # For Cheater Driven Development: uncomment the following line to save the 'actual' email
    # to the fixture file to make it the new 'expected' body
    #File.open("fixtures/reservation_mailer/confirm", 'w') {|f| f.write(actual.body) }
    
    assert_equal @expected.body, actual.body
    assert_equal @expected.subject, actual.subject
    assert_equal @expected.from, actual.from
    assert_equal @expected.to, actual.to
    
    # I'm apparently not smart enough to figure out how to test this properly with multipart emails with attachments. :-P
    # assert_equal @expected.encoded, ReservationMailer.create_confirm( reservations( :bill ), "http://test.url.com" ).encoded
  end

  test "remind" do
    @expected.subject = 'Reminder: Introduction to Gato'
    @expected.body    = read_fixture('remind')
    @expected.date    = Time.now
    @expected.from    = 'nobody@txstate.edu'
    @expected.to      = 'pu12345@dev.nul'

    actual = ReservationMailer.create_remind( reservations( :plainuser1 ) )
    
    # For Cheater Driven Development: uncomment the following line to save the 'actual' email
    # to the fixture file to make it the new 'expected' body
    #File.open("fixtures/reservation_mailer/remind", 'w') {|f| f.write(actual.body) }
    
    assert_equal @expected.body, actual.body
    assert_equal @expected.subject, actual.subject
    assert_equal @expected.from, actual.from
    assert_equal @expected.to, actual.to
    
    # I'm apparently not smart enough to figure out how to test this properly with multipart emails with attachments. :-P
    # assert_equal @expected.encoded, ReservationMailer.create_confirm( reservations( :bill ), "http://test.url.com" ).encoded
  end

  test "promote" do
    @expected.subject = 'Now Enrolled: Introduction to Gato'
    @expected.body    = read_fixture('promote')
    @expected.date    = Time.now
    @expected.from    = 'nobody@txstate.edu'
    @expected.to      = 'pu12345@dev.nul'

    actual = ReservationMailer.create_promotion_notice( reservations( :plainuser1 ) )
    
    # For Cheater Driven Development: uncomment the following line to save the 'actual' email
    # to the fixture file to make it the new 'expected' body
    #File.open("fixtures/reservation_mailer/promote", 'w') {|f| f.write(actual.body) }
    
    assert_equal @expected.body, actual.body
    assert_equal @expected.subject, actual.subject
    assert_equal @expected.from, actual.from
    assert_equal @expected.to, actual.to
    
    # I'm apparently not smart enough to figure out how to test this properly with multipart emails with attachments. :-P
    # assert_equal @expected.encoded, ReservationMailer.create_confirm( reservations( :bill ), "http://test.url.com" ).encoded
  end
  
  test "update" do
    @expected.subject = 'Class Details Updated: Introduction to Gato'
    @expected.body    = read_fixture('update')
    @expected.date    = Time.now
    @expected.from    = 'nobody@txstate.edu'
    @expected.to      = 'pu12345@dev.nul'

    actual = ReservationMailer.create_update_notice( reservations( :plainuser1 ) )
    
    # For Cheater Driven Development: uncomment the following line to save the 'actual' email
    # to the fixture file to make it the new 'expected' body
    #File.open("fixtures/reservation_mailer/update", 'w') {|f| f.write(actual.body) }
    
    assert_equal @expected.body, actual.body
    assert_equal @expected.subject, actual.subject
    assert_equal @expected.from, actual.from
    assert_equal @expected.to, actual.to
    
    # I'm apparently not smart enough to figure out how to test this properly with multipart emails with attachments. :-P
    # assert_equal @expected.encoded, ReservationMailer.create_confirm( reservations( :bill ), "http://test.url.com" ).encoded
  end

  test "cancel" do
    @expected.subject = 'Class Cancelled: Introduction to Gato'
    @expected.body    = read_fixture('cancel')
    @expected.date    = Time.now
    @expected.from    = 'nobody@txstate.edu'
    @expected.to      = 'pu12345@dev.nul'

    actual = ReservationMailer.create_cancellation_notice( reservations( :plainuser1 ) )
    
    # For Cheater Driven Development: uncomment the following line to save the 'actual' email
    # to the fixture file to make it the new 'expected' body
    #File.open("fixtures/reservation_mailer/cancel", 'w') {|f| f.write(actual.body) }
    
    assert_equal @expected.body, actual.body
    assert_equal @expected.subject, actual.subject
    assert_equal @expected.from, actual.from
    assert_equal @expected.to, actual.to
    
    # I'm apparently not smart enough to figure out how to test this properly with multipart emails with attachments. :-P
    # assert_equal @expected.encoded, ReservationMailer.create_confirm( reservations( :bill ), "http://test.url.com" ).encoded
  end
end
