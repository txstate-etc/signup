module ApplicationHelper

  def page_title(opts={})
    @page_title ||
      t(:title, opts.merge( scope: [controller_name, action_name], raise: true ))
  rescue
    t(:title, opts.merge( scope: [controller_name] ))
  end

  def logo_link_url
    if defined? ORG_URL
      ORG_URL
    else
      root_url
    end
  end

  # Like ActionView::Helpers::TextHelper::pluralize, but without the number
  def pluralize_word(count, singular, plural = nil)
    ((count == 1 || count == '1') ? singular : (plural || singular.pluralize))
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

    start = start.beginning_of_week(:sunday)
    last = last.end_of_week(:sunday)
        
    (start..last).to_a
  end

  def date_class(date, cur)
    (date.today? ? 'today ' : '') << ((date.month == cur.month && date.year == cur.year) ? 'cur-month' : '')
  end

  def survey_link(reservation, opts = {})
    return '' if reservation.cancelled? ||
      reservation.session.not_finished? || 
      reservation.attended == Reservation::ATTENDANCE_MISSED || 
      reservation.survey_response.present? || 
      reservation.session.topic.survey_type == 0 ||
      current_user.nil? ||
      current_user != reservation.user
    
    if reservation.session.topic.survey_type == Topic::SURVEY_INTERNAL
      url = new_survey_response_url + "?reservation_id=#{reservation.id}"
    elsif reservation.session.topic.survey_type == Topic::SURVEY_EXTERNAL
      url = reservation.session.topic.survey_url
    end

    content_tag(
      opts[:tag] || :div, 
      link_to('Take the survey!', url, :class => 'survey-link'),
      :class => 'survey-link'
    )
end
  
  def certificate_link(reservation, opts = {})
    return '' if reservation.cancelled? ||
      reservation.session.not_finished? || 
      reservation.attended != Reservation::ATTENDANCE_ATTENDED || 
      !reservation.session.topic.certificate ||
      current_user.nil? ||
      (!current_user.admin? && current_user != reservation.user)
 
    content_tag(
      opts[:tag] || :div,
      link_to('Download Certificate', certificate_reservation_url(reservation, :format => :pdf), :class => 'certificate-link'),
      :class => 'certificate-link'
    )
  end

  def expandible_list(items, visible: 5, allow_html: false)
    ret = '<div class="expandible-container"><ul>'
    items[0..(visible-1)].each do |item|
      item = strip_tags(item) unless allow_html
      ret << "<li>#{item}</li>" 
    end 
    ret << '</ul>'
    
    if items.size > visible
      ret << '<ul class="expandible" style="display:none;">'
      items.drop(visible).each do |item|
        item = strip_tags(item) unless allow_html
        ret << "<li>#{item}</li>"
      end
      ret << '</ul>'
      
      ret << '<a class="list-expand collapsed" style="display:block;" href="#">show more ▼</a>'
    end

    ret << '</div>'
    
    raw ret
  end

  def default_cancellation_message(session)
    "Sad news: the session on \"#{session.topic.name}\" for which you had signed up has been cancelled."
  end

  def model_error_messages(record, name=nil)
    return unless record.errors.any?
    name ||= record.class.model_name.human.downcase
    
    errors = record.errors.keys.map do |attr|
      msg = record.errors[attr].first
      msg += "." unless /[.!?]$/.match(msg)

      # Prepend the field name unless the first char of the msg is upper case. 
      /\A\p{Lu}/.match(msg) ? msg : "#{record.class.human_attribute_name(attr).capitalize} #{msg}"
    end

    ret = '<div id="error_explanation">'
    ret << "<h2>#{pluralize(errors.count, "error")} prohibited this #{name} from being saved</h2>"
    ret << '<p>There were problems with the following fields:</p>'
    ret << '<ul>'
    errors.each do |msg| 
      ret << "<li>#{msg}</li>"
    end
    ret << '</ul>'
    ret << '</div>'
    raw ret

  end

end
