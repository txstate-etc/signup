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
    return nil unless start_time && duration
    end_time = duration.minutes.since start_time
    start_time.strftime('%A, %B %e, %Y, ') + friendly_time(start_time) + " - " + friendly_time(end_time)
  end

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\", \"set_initial_#{association.to_s.singularize}_value\")"))
  end
end
