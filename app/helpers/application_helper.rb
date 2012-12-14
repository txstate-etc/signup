# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def pluralize_word(count, singular, plural = nil)
    ((count == 1 || count == '1') ? singular : (plural || singular.pluralize))
  end
  
  def pluralize_word_with_count(count, singular, plural = nil)
    "#{count} #{pluralize_word(count, singular, plural)}"
  end
  
  def friendly_time(time)
    if (time.hour == 12 && time.min == 0) 
      "Noon"
    elsif (time.hour == 0 && time.min == 0)
      "Midnight"
    else
      time.strftime('%l:%M%p')
    end  
  end
  
  def formatted_time_range(start_time, duration, include_date = true)
    return nil unless start_time && duration
    end_time = duration.minutes.since start_time
    s = ''
    s << start_time.strftime('%A, %B %e, %Y, ') if include_date
    s << friendly_time(start_time) << " - " << friendly_time(end_time)
  end

  def full_month(date)
    start = date.beginning_of_month
    last =  date.end_of_month

    # Rails thinks that the beginning_of_week is Monday. At least this is configurable in Rails >= 3.2
    start = start.beginning_of_week - 1 unless start.wday == 0
    last = last.end_of_week - 1 unless last.wday == 6
    
    (start..last).to_a
  end
  
  def date_class(date, cur)
    (date.today? ? 'today ' : '') << ((date.month == cur.month && date.year == cur.year) ? 'cur-month' : '')
  end
  
  def link_to_remove_fields(name, f, options={})
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", options)
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\", \"set_initial_#{association.to_s.singularize}_value\")"))
  end
  
  def survey_link(reservation)
    return '' if reservation.session.last_time > Time.now || 
      reservation.attended == Reservation::ATTENDANCE_MISSED || 
      reservation.survey_response.present? || 
      reservation.session.topic.survey_type == 0 ||
      current_user.nil? ||
      current_user != reservation.user
    
    if reservation.session.topic.survey_type == 1
      url = new_survey_response_url + "?reservation_id=#{reservation.id}"
    elsif reservation.session.topic.survey_type == 2
      url = reservation.session.topic.survey_url
    end
    link_to 'Take the survey!', url, :class => 'survey-link'
  end
  
  def expandible_list(comments, visible=5)
    ret = '<ul>'
    comments[0..(visible-1)].each do |comment| 
      ret << "<li>#{comment}</li>"
    end 
    ret << '</ul>'
    
    if comments.size > visible
      ret << '<ul style="display:none;">'
      comments.drop(visible).each do |comment|
        ret << "<li>#{comment}</li>"
      end
      ret << '</ul>'
      
      ret << list_expand_collapse_links
    end 

    ret
  end
  
  def list_expand_collapse_links()
    ret = '<div class="list-expand" style="display:block;">'
    ret << link_to_function("show more ▼", 'expand_list(this)')
    ret << '</div>'
    ret << '<div class="list-collapse" style="display:none;">'
    ret << link_to_function("show fewer ▲", 'collapse_list(this)')
    ret << '</div>'
  end
end
