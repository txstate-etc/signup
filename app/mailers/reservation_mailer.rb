#coding: UTF-8

class ReservationMailer < ActionMailer::Base
  include HtmlToPlainText
  helper :application, :topics

  def self.absolute_url(path)
    protocol = ActionMailer::Base.default_url_options[:protocol] || 'http://'
    host = ActionMailer::Base.default_url_options[:host] || 'localhost'
    port = ActionMailer::Base.default_url_options[:port] || ''
    
    port = ":#{port}" unless port.blank?
    path = '/' + path unless path.start_with? '/'
        
    protocol + host + port + path
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.reservation_mailer.confirm.subject
  #

  def confirm( reservation, user = nil )
    user ||= reservation.user
    create_ics_attachment(reservation.session)
    create_mail({
      subject: "Reservation Confirmation For: #{reservation.user.name}", 
      to: user.email_header, 
      from: reservation.session.instructors.first.email_header, 
      locals: { reservation: reservation, user: user }
    })
  end

  def confirm_instructor(reservation, user)
    confirm(reservation, user)
  end

  def remind( session, user )
    create_ics_attachment(session)
    create_mail({
      subject: "Reminder: #{session.topic.name}", 
      to: user.email_header, 
      from: session.instructors.first.email_header, 
      locals: { session: session, user: user }
    })
  end

  def remind_instructor(session, user)
    remind(session, user)
  end

  def promotion_notice( reservation, user = nil )
    user ||= reservation.user
    create_ics_attachment(reservation.session)
    create_mail({
      subject: "Now Enrolled: #{reservation.session.topic.name}", 
      to: user.email_header, 
      from: reservation.session.instructors.first.email_header, 
      locals: { reservation: reservation, user: user }
    })
  end

  def promotion_notice_instructor(reservation, user)
    promotion_notice(reservation, user)
  end

  def cancellation_notice( session, user, custom_message = '' )
    create_mail({
      subject: "Class Cancelled: #{session.topic.name}", 
      to: user.email_header, 
      from: session.instructors.first.email_header, 
      locals: { session: session, user: user, :custom_message => custom_message }
    })
  end

  def cancellation_notice_instructor(session, user, custom_message = '')
    cancellation_notice(session, user, custom_message)
  end

  def session_message( session, user, message )
    create_mail({
      subject: "Update: #{session.topic.name}", 
      to: user.email_header, 
      from: session.instructors.first.email_header, 
      locals: { session: session, user: user, :message => message }
    })
  end
  
  def session_message_instructor(session, user, message)
    session_message(session, user, message)
  end

  def update_notice( session, user )
    create_mail({
      subject: "Class Details Updated: #{session.topic.name}", 
      to: user.email_header, 
      from: session.instructors.first.email_header, 
      locals: { session: session, user: user }
    })
  end
  
  def update_notice_instructor(session, user)
    update_notice(session, user)
  end

  def followup( reservation )
    if (reservation.session.topic.survey_type != Topic::SURVEY_NONE)
      subject = 'Feedback Requested: ' + reservation.session.topic.name
    else 
      subject = 'Post-session Wrap-up: ' + reservation.session.topic.name
    end

    create_mail({
      subject: subject, 
      to: reservation.user.email_header, 
      from: reservation.session.instructors.first.email_header, 
      locals: { reservation: reservation }
    })
  end  

  def followup_instructor( session, user )
    create_mail({
      subject: "Post-session Wrap-up: #{session.topic.name}", 
      to: user.email_header, 
      from: session.instructors.first.email_header, 
      locals: { session: session, user: user }
    })
  end
  
  def accommodation_notice( reservation )
    create_mail({
      subject: "Special Accommodations Needed for: #{reservation.session.topic.name}", 
      to: reservation.session.instructors.collect {|i| i.email_header }, 
      from: reservation.user.email_header, 
      locals: { reservation: reservation }
    })
  end

  def raw_message( user, from_addr, subj, message )
    mail(
      subject: subj,
      to: user.email_header,
      from: from_addr,
      body: message
    )
  end

  private

  def create_ics_attachment(session)
    attachments['reservation.ics'] = {
      mime_type: 'text/calendar',
      content: session.to_cal 
    }
  end

  def create_mail(opts)
    mail_opts = opts.extract!(:subject, :to, :from)
    html = render_to_string(opts.merge(template: "#{mailer_name}/#{action_name}.html.erb"))
    text = convert_to_text(html)
    mail(mail_opts) do |format|
      format.html { render html: html }
      format.text { render plain: text }
    end
  end

end
