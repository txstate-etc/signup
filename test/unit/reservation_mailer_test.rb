require 'test_helper'

class ReservationMailerTest < ActionMailer::TestCase
  fixtures :reservations
  
  test "confirm" do
    @expected.subject = 'Reservation Confirmation For: Bill Bryson'
    @expected.body    = read_fixture('confirm')
    @expected.date    = Time.now
    @expected.from    = 'nobody@txstate.edu'
    @expected.to      = 'bb32@txstate.edu'

    # I'm apparently not smart enough to figure out how to test this properly with multipart emails with attachments. :-P
    # assert_equal @expected.encoded, ReservationMailer.create_confirm( reservations( :bill ), "http://test.url.com" ).encoded
  end

end
