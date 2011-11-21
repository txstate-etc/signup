module TopicsHelper

  def link_to_session(session)
    session_info = "#{formatted_time_range(session.time, session.topic.minutes)} ("
    session_info << " #{session.confirmed_reservations.size}"
    if session.seats
      session_info << " / #{session.seats}"
    end 
      session_info << " registered"
    if session.waiting_list.size > 0 
      session_info << ", #{session.waiting_list.size} waiting"
    end
    session_info << " )"
    link_to session_info, session
  end

end
