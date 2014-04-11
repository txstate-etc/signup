module TopicsHelper

  def session_info(session, opts={})
    print_date = !(opts[:print_date] == false) #default to true unless explicitly set to false    
    session_info = ""
    session_info << "#{session.topic.name} " if opts[:print_name] == true
    session_info << "#{formatted_time_range(session.time, session.topic.minutes, print_date)} ("
    session_info << " #{session.confirmed_count}"
    if session.seats
      session_info << " / #{session.seats}"
    end 
      session_info << " registered"
    if session.waiting_list_count > 0 
      session_info << ", #{session.waiting_list_count} waiting"
    end
    session_info << " )"
  end

  def link_to_session(session, opts={})
    link_to session_info(session, opts), session
  end
  
  def session_site(session)
    if session.site 
      s = '<span class="site'
      s << ' default' if session.site.default?
      s << '">'
      s << session.site.name 
      s << '</span>'
      s
    end
  end

  def session_time_short(session)
    # strftime doesn't have the formats we want on OSX. We'll
    # have to do this the hard way
    time = session.time
    "#{time.month}/#{time.day}/#{time.strftime('%Y&nbsp;%l:%M%p')}"
  end

  def session_reservations_short(session)
    s = "#{session.confirmed_count}"
    s << " / #{session.seats}" if session.seats
    s
  end
  
  def session_list(sessions)
    list = sessions.map do |session| 
      "#{link_to_session(session)} #{session_site(session)}"
    end
    
    expandible_list list, 12
  end
  
  def department_select(f)
    # for existing topics, only admins can modify dept
    # for new topics, limit selection to user's departments (for editors. Admins can select any dept).
    disabled = !(current_user.admin? || f.object.new_record?)
    departments = current_user.admin? ? Department.active : current_user.departments
    include_blank = f.object.new_record? && departments.size > 1
    f.collection_select :department_id, departments, :id, :name, { :include_blank => include_blank }, { :disabled => disabled }
  end
end
