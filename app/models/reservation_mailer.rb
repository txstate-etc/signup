class ReservationMailer < ActionMailer::Base
  

  def confirm( reservation, url )
    subject    'Reservation Confirmation For: ' + reservation.user.name
    recipients reservation.user.email
    from       'nobody@txstate.edu'
    content_type 'multipart/alternative'
    
    part :content_type => "text/plain",
      :body => render_message( "confirm-as-text", :reservation => reservation, :url => url ),
      :transfer_encoding => "base64"
    
    part :content_type => "text/html",
      :body => render_message( "confirm-as-html", :reservation => reservation, :url => url )
    
    attachment :content_type => "text/calendar", :body => reservation.session.to_cal
  end

  def remind( reservation, url )
    subject    'Reminder: ' + reservation.session.topic.name
    recipients reservation.user.email
    from       'nobody@txstate.edu'
    content_type 'multipart/alternative'
    
    part :content_type => "text/plain",
      :body => render_message( "remind-as-text", :reservation => reservation, :url => url ),
      :transfer_encoding => "base64"
    
    part :content_type => "text/html",
      :body => render_message( "remind-as-html", :reservation => reservation, :url => url )
    
    attachment :content_type => "text/calendar", :body => reservation.session.to_cal
  end

end
