# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def friendly_time(time)
    if (time.hour == 12 && time.min == 0) 
      "Noon"
    elsif (time.hour == 0 && time.min == 0)
      "Midnight"
    else
      time.strftime('%l:%M%p')
    end  
  end
  
  def formatted_time_range(start_time, duration)
    end_time = duration.minutes.since start_time
    start_time.strftime('%A, %B %d %Y ') + friendly_time(start_time) + " - " + friendly_time(end_time)
  end

end
