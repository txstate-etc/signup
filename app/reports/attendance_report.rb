class AttendanceReport < Prawn::Document
  include ApplicationHelper
  
  def to_pdf(session)
    first_occurrence = true
      
    session.occurrences.each do |occurrence|
      start_new_page unless first_occurrence
      first_occurrence = false
      first_page = page_count
      total_pages = 1
      items = session.confirmed_reservations_by_last_name
      while items.size > 0
        page_header(session, occurrence)
        bounding_box([20,630], :width => 500, :height =>550) do
          [12, items.size].min.times do
            item = items.shift
            bounding_box([0,cursor], :width => 500, :height =>48) do
              stroke_bounds
              pad(14) do 
                indent(5) do           
                  text item.user.name, :size => 14
                  text attendance_entry_line2(item.user), :size => 12, :style => :italic
                end          
              end
            end 
          end
        end
        if items.size > 0
          start_new_page
          total_pages = total_pages + 1
        end 
      end
          
      number_pages "Page <page> of <total>", { :at => [bounds.right - 150, 0],
              :width => 150,
              :align => :right,
              :page_filter => (first_page..page_count),
              :start_count_at => 1,
              :total_pages => total_pages} 
    end
    
    render
  end

  protected
  def page_header(session, occurrence)
    text_box session.topic.name, :at => [20, 730], :size => 16, :align => :center, :style => :bold, :single_line => true, :overflow => :ellipses
    text_box session.loc_with_site, :at => [20, 710], :size => 14, :align => :center, :style => :bold, :single_line => true, :overflow => :ellipses
    text_box formatted_time_range(occurrence.time, session.topic.minutes), :at => [20, 690], :size => 14, :align => :center, :style => :bold
    text_box "Attendance List", :at => [20, 650], :size => 14, :align => :center, :style => :bold          
  end
  
  def attendance_entry_line2(user)
    line2 = ""
    line2 << user.email if user.email
    line2 << ", " if user.email && user.department
    line2 << user.department if user.department
    line2
  end

end