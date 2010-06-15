class ReservationMailer < ActionMailer::Base
  

  def confirm( reservation, url )
    subject    'Reservation Confirmation For: ' + reservation.name
    recipients reservation.login + "@txstate.edu"
    from       'nobody@txstate.edu'
    content_type 'multipart/alternative'
    
    part :content_type => "text/plain",
      :body => render_message( "confirm-as-text", :reservation => reservation, :url => url ),
      :transfer_encoding => "base64"
    
    part :content_type => "text/html",
      :body => render_message( "confirm-as-html", :reservation => reservation, :url => url )
    
    attachment :content_type => "text/calendar", :body => reservation.to_cal
  end

end
