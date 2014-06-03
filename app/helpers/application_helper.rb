module ApplicationHelper

  def page_title(opts={})
    @page_title ||
      t(:title, opts.merge( scope: [controller_name, action_name], raise: true ))
  rescue
    t(:title, opts.merge( scope: [controller_name] ))
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

  def expandible_list(items, visible=5)
    ret = '<div class="expandible-container"><ul>'
    items[0..(visible-1)].each do |item| 
      ret << "<li>#{item}</li>"
    end 
    ret << '</ul>'
    
    if items.size > visible
      ret << '<ul class="expandible" style="display:none;">'
      items.drop(visible).each do |item|
        ret << "<li>#{item}</li>"
      end
      ret << '</ul>'
      
      ret << '<a class="list-expand collapsed" style="display:block;" href="#">show more ▼</a>'
    end

    ret << '</div>'
    
    raw ret
  end

end
