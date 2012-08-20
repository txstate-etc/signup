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

  def session_time_short(session)
    # strftime doesn't have the formats we want on OSX. We'll
    # have to do this the hard way
    time = session.time
    "#{time.month}/#{time.day}/#{time.strftime('%Y&nbsp;%l:%M%p')}"
  end

  def session_reservations_short(session)
    s = "#{session.confirmed_reservations.size}"
    s << " / #{session.seats}" if session.seats
    s
  end
  
  def session_list(sessions)
    expandible_list sessions.map{|session| link_to_session(session)}
  end
  
  def department_select(f)
    # for existing topics, only admins can modify dept
    # for new topics, limit selection to user's departments (for non-admins. Admins can select any dept).
    disabled = !(current_user.admin? || f.object.new_record?)
    departments = current_user.admin? ? Department.all : current_user.departments
    include_blank = f.object.new_record? && departments.size > 1
    f.collection_select :department_id, departments, :id, :name, { :include_blank => include_blank }, { :disabled => disabled }
  end
end
