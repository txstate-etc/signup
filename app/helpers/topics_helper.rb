module TopicsHelper

  def session_info(session)
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
  end

  def link_to_session(session)
    link_to session_info(session), session
  end

  def session_list(sessions)
    ret = '<ul class="session-list">'
    sessions[0..4].each do |session| 
      ret << "<li>#{link_to_session(session)}</li>"
    end 
    ret << '</ul>'
    
    if sessions.size > 5
      ret << '<ul class="session-list" style="display:none;">'
      sessions.drop(5).each do |session|
        ret << "<li>#{link_to_session(session)}</li>"
      end
      ret << '</ul>'
      
      ret << '<div class="session-list-expand" style="display:inline;">'
      ret << link_to_function("show more ▼", 'expand_session_list(this)')
      ret << '</div>'
      ret << '<div class="session-list-collapse" style="display:none;">'
      ret << link_to_function("show fewer ▲", 'collapse_session_list(this)')
      ret << '</div>'
    end 

    ret
  end
  
end
