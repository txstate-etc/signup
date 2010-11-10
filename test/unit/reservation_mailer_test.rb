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

end
