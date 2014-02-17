require 'test_helper'

class ReservationMailerTest < ActionMailer::TestCase
  fixtures :reservations
  
  def fixture_name(ext, full_path=false)
    path = "#{@method_name.sub(/test_/, '')}.#{ext}"
    full_path ? "#{Rails.root}/test/fixtures/reservation_mailer/#{path}" : path
  end
  
  def read_combined_fixture
    parts = []
    begin
      parts << read_fixture("#{fixture_name('txt')}").to_s
      parts << read_fixture("#{fixture_name('html')}").to_s
      parts << read_fixture("#{fixture_name('ics')}").to_s
    rescue
    end
    parts
  end
  
  def write_fixture(mail)
    # For Cheater Driven Development: comment out the following line to save the 'actual' email
    # to the fixture file to make it the new 'expected' body
    return unless defined? UPDATE_FIXTURES
    
    types = [
       { :ext => 'txt', :mime => 'plain' },
       { :ext => 'html', :mime => 'html' },
       { :ext => 'ics', :mime => 'calendar' },
      ]
    
    types.each do |type|  
      part = mail.parts.find { |part| part.content_type =~ /#{type[:mime]}/ }
      next unless part
      File.open(fixture_name(type[:ext], true), 'w') do |f|
        f.write(part.body) 
      end
    end
  end
  
  def do_common_assertions()
    expected_parts = read_combined_fixture
    write_fixture(@actual)

    #assert_equal @expected.body, @actual.body
    assert_equal @expected.subject, @actual.subject
    assert_equal @expected.from, @actual.from
    assert_equal @expected.to, @actual.to
    
    assert_equal expected_parts.length, @actual.parts.length
    expected_parts.each_index do |i|
      assert_equal expected_parts[i], @actual.parts[i].body
    end
   
  end
  
  test "confirm" do
    @expected.subject = 'Reservation Confirmation For: Plain User1'
    #@expected.body    = ???
    @expected.date    = Time.now
    @expected.from    = 'i12345@dev.nul'
    @expected.to      = 'pu12345@dev.nul'

    @actual = ReservationMailer.create_confirm( reservations( :plainuser1 ) )
    
    do_common_assertions 
  end

  test "remind" do
    @expected.subject = 'Reminder: Introduction to Gato'
    #@expected.body    = ???
    @expected.date    = Time.now
    @expected.from    = 'i12345@dev.nul'
    @expected.to      = 'pu12345@dev.nul'

    reservation = reservations( :plainuser1 )
    @actual = ReservationMailer.create_remind( reservation.session, reservation.user )
    
    do_common_assertions 
  end

  test "remind_instructor" do
    @expected.subject = 'Reminder: Introduction to Gato'
    #@expected.body    = ???
    @expected.date    = Time.now
    @expected.from    = 'i12345@dev.nul'
    @expected.to      = 'i12345@dev.nul'

    reservation = reservations( :plainuser1 )
    @actual = ReservationMailer.create_remind_instructor( reservation.session, reservation.session.instructors[0] )
    
    do_common_assertions 
  end

  test "promote" do
    @expected.subject = 'Now Enrolled: Introduction to Gato'
    #@expected.body    = ???
    @expected.date    = Time.now
    @expected.from    = 'i12345@dev.nul'
    @expected.to      = 'pu12345@dev.nul'

    @actual = ReservationMailer.create_promotion_notice( reservations( :plainuser1 ) )
    
    do_common_assertions 
  end
  
  test "update" do
    @expected.subject = 'Class Details Updated: Introduction to Gato'
    #@expected.body    = ???
    @expected.date    = Time.now
    @expected.from    = 'i12345@dev.nul'
    @expected.to      = 'pu12345@dev.nul'

    reservation = reservations( :plainuser1 )
    @actual = ReservationMailer.create_update_notice( reservation.session, reservation.user )
    
    do_common_assertions 
  end

  test "update_instructor" do
    @expected.subject = 'Class Details Updated: Introduction to Gato'
    #@expected.body    = ???
    @expected.date    = Time.now
    @expected.from    = 'i12345@dev.nul'
    @expected.to      = 'i12345@dev.nul'

    reservation = reservations( :plainuser1 )
    @actual = ReservationMailer.create_update_notice_instructor( reservation.session, reservation.session.instructors[0] )
    
    do_common_assertions 
  end
  
  CANCEL_MSG = "Zombies ate the instructor's brain, and we cannot find a replacement at this short notice."

  test "cancel" do
    @expected.subject = 'Class Cancelled: Introduction to Gato'
    #@expected.body    = ???
    @expected.date    = Time.now
    @expected.from    = 'i12345@dev.nul'
    @expected.to      = 'pu12345@dev.nul'

    reservation = reservations( :plainuser1 )
    @actual = ReservationMailer.create_cancellation_notice( reservation.session, reservation.user, CANCEL_MSG )
    
    do_common_assertions 
  end

  test "cancel_instructor" do
    @expected.subject = 'Class Cancelled: Introduction to Gato'
    #@expected.body    = ???
    @expected.date    = Time.now
    @expected.from    = 'i12345@dev.nul'
    @expected.to      = 'i12345@dev.nul'

    reservation = reservations( :plainuser1 )
    @actual = ReservationMailer.create_cancellation_notice_instructor( reservation.session, reservation.session.instructors[0], CANCEL_MSG )
    
    do_common_assertions 
  end
  
  test "accommodations_added" do
    @expected.subject = 'Special Accommodations Needed for: Teaching with TRACS'
    #@expected.body    = ???
    @expected.date    = Time.now
    @expected.from    = 'pu12345@dev.nul'
    @expected.to      = ['i12345@dev.nul', 'i23456@dev.nul']

    @actual = ReservationMailer.create_accommodation_notice( reservations( :tracs_multiple_instructors_plainuser1 ) )
    
    do_common_assertions 
  end

  test "accommodations_removed" do
    @expected.subject = 'Special Accommodations Needed for: Introduction to Gato'
    #@expected.body    = ???
    @expected.date    = Time.now
    @expected.from    = 'pu12345@dev.nul'
    @expected.to      = 'i12345@dev.nul'

    @actual = ReservationMailer.create_accommodation_notice( reservations( :plainuser1 ) )
    
    do_common_assertions 
  end

  test "survey_internal" do
    @expected.subject = 'Feedback Requested: Introduction to Gato'
    #@expected.body    = ???
    @expected.date    = Time.now
    @expected.from    = 'i12345@dev.nul'
    @expected.to      = 'pu12345@dev.nul'

    @actual = ReservationMailer.create_followup( reservations( :plainuser1 ) )
 
    do_common_assertions 
  end
  
  test "survey_external" do
    @expected.subject = 'Feedback Requested: Teaching with TRACS'
    #@expected.body    = ???
    @expected.date    = Time.now
    @expected.from    = 'i12345@dev.nul'
    @expected.to      = 'pu12345@dev.nul'

    @actual = ReservationMailer.create_followup( reservations( :tracs_multiple_instructors_plainuser1 ) )
 
    do_common_assertions 
  end
  
  test "survey_instructor_internal" do
    @expected.subject = 'Post-session Wrap-up: Introduction to Gato'
    #@expected.body    = ???
    @expected.date    = Time.now
    @expected.from    = 'i12345@dev.nul'
    @expected.to      = 'i12345@dev.nul'

    reservation = reservations( :plainuser1 )
    @actual = ReservationMailer.create_followup_instructor( reservation.session, reservation.session.instructors[0] )
 
    do_common_assertions 
  end
  
  test "survey_instructor_external" do
    @expected.subject = 'Post-session Wrap-up: Teaching with TRACS'
    #@expected.body    = ???
    @expected.date    = Time.now
    @expected.from    = 'i12345@dev.nul'
    @expected.to      = 'i12345@dev.nul'

    reservation = reservations( :tracs_multiple_instructors_plainuser1 )
    @actual = ReservationMailer.create_followup_instructor( reservation.session, reservation.session.instructors[0] )
 
    do_common_assertions 
  end
  
  test "session_message" do
    @expected.subject = 'Update: Teaching with TRACS'
    #@expected.body    = ???
    @expected.date    = Time.now
    @expected.from    = 'i12345@dev.nul'
    @expected.to      = 'pu12345@dev.nul'

    reservation = reservations( :tracs_multiple_instructors_plainuser1 )
    @actual = ReservationMailer.create_session_message( reservation.session, reservation.user, "Don't forget to bring a towel!" )
 
    do_common_assertions 
  end

  test "session_message_instructor" do
    @expected.subject = 'Update: Teaching with TRACS'
    #@expected.body    = ???
    @expected.date    = Time.now
    @expected.from    = 'i12345@dev.nul'
    @expected.to      = 'i12345@dev.nul'

    reservation = reservations( :tracs_multiple_instructors_plainuser1 )
    @actual = ReservationMailer.create_session_message_instructor( reservation.session, reservation.session.instructors[0], "Don't forget to bring a towel!" )
 
    do_common_assertions 
  end
  
  test "Should generate sane urls" do
    host = ActionMailer::Base.default_url_options[:host]
    port = ActionMailer::Base.default_url_options[:port]
    path = 'path/to/some/file.txt'
    
    assert_equal 'http://localhost:3000/' + path, ReservationMailer.absolute_url(path)
    assert_equal 'http://localhost:3000/' + path, ReservationMailer.absolute_url('/' + path)
    ActionMailer::Base.default_url_options[:host] = "www.example.com"
    ActionMailer::Base.default_url_options[:port] = nil
    assert_equal 'http://www.example.com/' + path, ReservationMailer.absolute_url(path)
    
    # reset host and port back to configured values
    ActionMailer::Base.default_url_options[:host] = host
    ActionMailer::Base.default_url_options[:port] = port
  end
end
