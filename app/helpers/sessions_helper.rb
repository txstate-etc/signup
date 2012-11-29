module SessionsHelper
  def registration_period(session)
    start_time = session.reg_start.blank? ? session.created_at : session.reg_start
    end_time = session.reg_end.blank? ? "the start of class." : session.reg_end
    return "From #{start_time} until #{end_time}"
  end

  def mailto_all(session, outlook=false)
    sep = outlook ? ';' : ','
    recipients = session.instructors.map { |user| user.email } unless session.instructors.blank?
    recipients << session.confirmed_reservations_by_last_name.map { |r| r.user.email } unless session.confirmed_reservations.blank?
    
    mailto = "mailto:#{session.instructors[0].email}"
    mailto << "?subject=Update: #{session.topic.name}"
    mailto << '&bcc=' << recipients.join(sep)
    mailto
  end
end
