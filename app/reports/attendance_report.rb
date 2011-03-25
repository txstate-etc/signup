class AttendanceReport < Prawn::Document

  def to_pdf(session)
    create_stamp("page_header") do
      text_box session.topic.name, :at => [20, 730], :size => 16, :align => :center, :style => :bold, :single_line => true, :overflow => :ellipses
      text_box session.location, :at => [20, 710], :size => 14, :align => :center, :style => :bold, :single_line => true, :overflow => :ellipses
      text_box session.time.to_s, :at => [20, 690], :size => 14, :align => :center, :style => :bold
      text_box "Attendance List", :at => [20, 650], :size => 14, :align => :center, :style => :bold      
    end
    
    items = session.confirmed_reservations
    while items.size > 0
      stamp("page_header")
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
      start_new_page if items.size > 0
    end
        
    number_pages "Page <page> of <total>", [bounds.right - 50, 0] 
    render
  end

  protected
  def attendance_entry_line2(user)
    line2 = ""
    line2 << user.email if user.email
    line2 << ", " if user.email && user.department
    line2 << user.department if user.department
    line2
  end

end