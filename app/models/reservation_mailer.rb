class ReservationMailer < ActionMailer::Base
  helper :application
  include HtmlToPlainText
  
  def self.absolute_url(path)
    protocol = ActionMailer::Base.default_url_options[:protocol] || 'http://'
    host = ActionMailer::Base.default_url_options[:host] || 'localhost'
    port = ActionMailer::Base.default_url_options[:port] || ''
    
    port = ':' + port unless port.empty?
    path = '/' + path unless path.start_with? '/'
        
    protocol + host + port + path
  end

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
    render_multipart :reservation => reservation
    attachment :content_type => "text/calendar", :body => reservation.session.to_cal
  end

  def remind( session, user )
    subject    'Reminder: ' + session.topic.name
    recipients user.email_header
    from       session.instructors[0].email_header
    render_multipart :session => session, :user => user
    attachment :content_type => "text/calendar", :body => session.to_cal
  end

  def promotion_notice( reservation )
    subject    'Now Enrolled: ' + reservation.session.topic.name
    recipients reservation.user.email_header
    from       reservation.session.instructors[0].email_header
    render_multipart :reservation => reservation
    attachment :content_type => "text/calendar", :body => reservation.session.to_cal
  end

  def cancellation_notice( session, user, custom_message = '' )
    subject    'Class Cancelled: ' + session.topic.name
    recipients user.email_header
    from       session.instructors[0].email_header
    render_multipart :session => session, :user => user, :custom_message => custom_message
  end

  def session_message( session, user, message )
    subject    'Update: ' + session.topic.name
    recipients user.email_header
    from       session.instructors[0].email_header
    render_multipart :session => session, :user => user, :message => message
  end
  
  def update_notice( reservation )
    subject    'Class Details Updated: ' + reservation.session.topic.name
    recipients reservation.user.email_header
    from       reservation.session.instructors[0].email_header
    render_multipart :reservation => reservation
  end
  
  def survey_mail( reservation )
    subject    'Feedback Requested: ' + reservation.session.topic.name
    recipients reservation.user.email_header
    from       reservation.session.instructors[0].email_header
    render_multipart :reservation => reservation
  end  
  
  def accommodation_notice( reservation )
    subject    'Special Accommodations Needed for: ' + reservation.session.topic.name
    recipients reservation.session.instructors.collect {|i| i.email_header }
    from       reservation.user.email_header
    render_multipart :reservation => reservation
  end

  private
  
  def render_multipart(opts={})
    html = render_message(@template, opts)
    text = convert_to_text(html)

    content_type 'multipart/alternative'
    part :content_type => "text/plain",
      :body => text,
      :transfer_encoding => "base64"
    
    part :content_type => "text/html",
      :body => html
  end

end
