module SessionsHelper
  def registration_period(session)
    start_time = session.reg_start.blank? ? session.created_at : session.reg_start
    end_time = session.reg_end.blank? ? "the start of class." : session.reg_end
    return "From #{start_time} until #{end_time}"
  end
end
