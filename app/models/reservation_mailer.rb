class ReservationMailer < ActionMailer::Base
  

  def confirm( reservation )
    subject    'Reservation Confirmation For: ' + reservation.user.name
    recipients reservation.user.email
    from       'nobody@txstate.edu'
    content_type 'multipart/alternative'
        
    part :content_type => "text/plain",
      :body => render_message( "confirm-as-text", :reservation => reservation ),
      :transfer_encoding => "base64"
    
    part :content_type => "text/html",
      :body => render_message( "confirm-as-html", :reservation => reservation )
    
    attachment :content_type => "text/calendar", :body => reservation.session.to_cal
  end

  def remind( reservation )
    subject    'Reminder: ' + reservation.session.topic.name
    recipients reservation.user.email
    from       'nobody@txstate.edu'
    content_type 'multipart/alternative'
    
    part :content_type => "text/plain",
      :body => render_message( "remind-as-text", :reservation => reservation ),
      :transfer_encoding => "base64"
    
    part :content_type => "text/html",
      :body => render_message( "remind-as-html", :reservation => reservation )
    
    attachment :content_type => "text/calendar", :body => reservation.session.to_cal
  end

  def promotion_notice( reservation )
    subject    'Now Enrolled: ' + reservation.session.topic.name
    recipients reservation.user.email
    from       'nobody@txstate.edu'
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
    recipients reservation.user.email
    from       'nobody@txstate.edu'
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
    recipients reservation.user.email
    from       'nobody@txstate.edu'
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
    recipients reservation.user.email
    from       'nobody@txstate.edu'
    content_type 'multipart/alternative'
    
    part :content_type => "text/plain",
      :body => render_message( "survey-mail-as-text", :reservation => reservation ),
      :transfer_encoding => "base64"
    
    part :content_type => "text/html",
      :body => render_message( "survey-mail-as-html", :reservation => reservation )
    
  end  
  
  def accommodation_notice( reservation )
    subject    'Special Accommodations Needed for: ' + reservation.session.topic.name
    recipients reservation.session.instructors.collect {|i| i.email }
    from       'nobody@txstate.edu'
    content_type 'multipart/alternative'
    
    part :content_type => "text/plain",
      :body => render_message( "accommodation-notice-as-text", :reservation => reservation ),
      :transfer_encoding => "base64"
    
    part :content_type => "text/html",
      :body => render_message( "accommodation-notice-as-html", :reservation => reservation )
  end

end
