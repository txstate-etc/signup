class ReservationMailer < ActionMailer::Base
  helper :application

  def deliver!(mail = @mail)
    # do pre-deliver stuff
    logger.info("Sending #{@template} mail at #{@sent_on.to_s}...")  
    
    begin
      super
    rescue Exception => e  # Net::SMTP errors or sendmail pipe errors
      logger.error("Error sending #{@template} mail: #{e.message}")
      logger.flush
      raise e
    end
          
    # do post-deliver stuff (catch exceptions, do exception stuff, and re-throw)
    logger.info("#{@template} mail sent successfully")  
    logger.flush
  end

  def confirm( reservation )
    subject    'Reservation Confirmation For: ' + reservation.user.name
    recipients reservation.user.email_header
    from       reservation.session.instructors[0].email_header
    content_type 'multipart/alternative'
        
    part :content_type => "text/plain",
      :body => render_message( "confirm-as-text", :reservation => reservation ),
      :transfer_encoding => "base64"
    
    part :content_type => "text/html",
      :body => render_message( "confirm-as-html", :reservation => reservation )
    
    attachment :content_type => "text/calendar", :body => reservation.session.to_cal
  end

  def remind( session, user )
    subject    'Reminder: ' + session.topic.name
    recipients user.email_header
    from       session.instructors[0].email_header
    content_type 'multipart/alternative'
    
    part :content_type => "text/plain",
      :body => render_message( "remind-as-text", :session => session, :user => user ),
      :transfer_encoding => "base64"
    
    part :content_type => "text/html",
      :body => render_message( "remind-as-html", :session => session, :user => user )
    
    attachment :content_type => "text/calendar", :body => session.to_cal
  end

  def promotion_notice( reservation )
    subject    'Now Enrolled: ' + reservation.session.topic.name
    recipients reservation.user.email_header
    from       reservation.session.instructors[0].email_header
    content_type 'multipart/alternative'
    
    part :content_type => "text/plain",
      :body => render_message( "promotion-notice-as-text", :reservation => reservation ),
      :transfer_encoding => "base64"
    
    part :content_type => "text/html",
      :body => render_message( "promotion-notice-as-html", :reservation => reservation )
    
    attachment :content_type => "text/calendar", :body => reservation.session.to_cal
  end

  def cancellation_notice( reservation )
    subject    'Class Cancelled: ' + reservation.session.topic.name
    recipients reservation.user.email_header
    from       reservation.session.instructors[0].email_header
    content_type 'multipart/alternative'
    
    url = url_for( :controller => "reservations" )
    
    part :content_type => "text/plain",
      :body => render_message( "cancellation-notice-as-text", :reservation => reservation ),
      :transfer_encoding => "base64"
    
    part :content_type => "text/html",
      :body => render_message( "cancellation-notice-as-html", :reservation => reservation )
    
  end
  
  def update_notice( reservation )
    subject    'Class Details Updated: ' + reservation.session.topic.name
    recipients reservation.user.email_header
    from       reservation.session.instructors[0].email_header
    content_type 'multipart/alternative'
    
    url = url_for( :controller => "reservations" )
    
    part :content_type => "text/plain",
      :body => render_message( "update-notice-as-text", :reservation => reservation ),
      :transfer_encoding => "base64"
    
    part :content_type => "text/html",
      :body => render_message( "update-notice-as-html", :reservation => reservation )
    
  end
  
  def survey_mail( reservation )
    subject    'Feedback Requested: ' + reservation.session.topic.name
    recipients reservation.user.email_header
    from       reservation.session.instructors[0].email_header
    content_type 'multipart/alternative'
    
    part :content_type => "text/plain",
      :body => render_message( "survey-mail-as-text", :reservation => reservation ),
      :transfer_encoding => "base64"
    
    part :content_type => "text/html",
      :body => render_message( "survey-mail-as-html", :reservation => reservation )
    
  end  
  
  def accommodation_notice( reservation )
    subject    'Special Accommodations Needed for: ' + reservation.session.topic.name
    recipients reservation.session.instructors.collect {|i| i.email_header }
    from       reservation.user.email_header
    content_type 'multipart/alternative'
    
    part :content_type => "text/plain",
      :body => render_message( "accommodation-notice-as-text", :reservation => reservation ),
      :transfer_encoding => "base64"
    
    part :content_type => "text/html",
      :body => render_message( "accommodation-notice-as-html", :reservation => reservation )
  end

end
