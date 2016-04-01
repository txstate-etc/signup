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
      s = '<span class="site">'
      s << session.site.name 
      s << '</span>'
      raw s
    end
  end

  def session_time_short(session)
    # strftime doesn't have the formats we want on OSX. We'll
    # have to do this the hard way
    time = session.time
    "#{time.month}/#{time.day}/#{time.strftime('%Y&nbsp;%l:%M%p')}".html_safe
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
    
    expandible_list list, visible: 12, allow_html: true
  end

  def link_to_document(d, opts = {})
    text = file_icon_image_tag(d.item.original_filename)
    text << ' ' << d.friendly_name
    link_to(text, asset_url(d.item.url), opts)
  end

  def file_icon_image_tag(filename, opts={})
    file_icon = FileIcon.new(filename)

    url = file_icon.icon_path
    
    opts = { :alt => t(:'file_icon.type', :type => (file_icon.type || filename)) }.merge opts
    image_tag(url, opts)
  end

  def grouped_by_date(topics)
    sessions = Hash.new { |h,k| h[k] = Array.new }
    topics.each do |topic|
      topic.upcoming_sessions.each do |session| 
        sessions[session.time.to_date] << session 
      end
    end
    
    sessions.keys.sort.each do |date| 
      yield date, sessions[date].sort_by(&:time)
    end if block_given?

    sessions
  end

  def grouped_by_department(topics)
    groups = Hash.new { |h,k| h[k] = Array.new }
    topics.each do |topic|
      groups[topic.department] << topic 
    end
    
    groups.keys.sort_by {|a| a.name.downcase }.each do |department| 
      yield department, groups[department].sort_by {|a| a.name.downcase }
    end if block_given?

    groups
  end

  def grouped_by_site(topics)
    sessions = Hash.new { |h,k| h[k] = Hash.new }
    topics.each do |topic|
      topic.upcoming_sessions.each do |session| 
        sessions[session.site][topic] = session if session.site && sessions[session.site][topic] == nil
      end
    end

    sessions.keys.sort.each do |site|
      yield site, sessions[site]
    end if block_given?

    sessions
  end

  def in_month(month)
    occurrences = Hash.new { |h,k| h[k] = Array.new }
    Occurrence.in_month(month).each do |occurrence|
      occurrences[occurrence.time.to_date] << occurrence
    end

    occurrences
  end

  def department_select(f)
    # for existing topics, only admins can modify dept
    # for new topics, limit selection to user's departments (for editors. Admins can select any dept).
    disabled = !(current_user.admin? || f.object.new_record?)
    departments = current_user.admin? ? Department.active.by_name : current_user.departments.by_name
    include_blank = f.object.new_record? && departments.size > 1
    f.association :department,
      label: 'Department:', 
      collection: departments, 
      value_method: :id, 
      label_method: :name, 
      :include_blank => include_blank, 
      :disabled => disabled
  end
end
