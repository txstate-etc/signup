class CompletionCertificate < Prawn::Document
  include ApplicationHelper
  
  FONT_SIZE = 18
  LINE_HEIGHT = (FONT_SIZE * 1.3).ceil
  LINE_SPACING = LINE_HEIGHT + 10
  TOP = 455

  def initialize
    super(:page_layout => :landscape)
  end

  def to_pdf(reservation)
    self.line_width = 3
    self.join_style = :bevel
    stroke_color '836c31'
    stroke_bounds

    bounding_box([5,535], :width => 710, :height =>530) do

      self.line_width = 1
      self.join_style = :miter
      stroke_color '501214'
      stroke_bounds
        
      bounding_box([15,535], :width => 680, :height =>530) do
        pad(25) do 

          stroke_color '444444'
          fill_color '836c31'
          text 'Certificate of Completion', :mode => :fill_stroke, :size => 48, :style => :italic, :align => :center
          
          fill_color '000000'

          static 'This is to certify that'
          dynamic reservation.user.name
          static 'has successfully completed the course'
          dynamic reservation.session.topic.name, :height => 2*LINE_HEIGHT, :overflow => :shrink_to_fit
          static 'on', :ydelta => 1.7*LINE_SPACING
          dynamic reservation.session.last_time.strftime('%A, %B %e, %Y')
          static 'taught by'
          dynamic reservation.session.instructors.map {|i| i.name }.join(',')
          dynamic reservation.session.topic.department.name, :ydelta => LINE_HEIGHT
          dynamic I18n.t(:organization), :ydelta => LINE_HEIGHT
          if (File.exists?("#{Rails.root}/public/images/cert-logo.jpg"))
            image "#{Rails.root}/public/images/cert-logo.jpg", :position => :center, :vposition => :bottom
          end
        end
      end
    end
          
    render
  end

  protected

  def static(str, opts={})
    text_box str, text_opts(opts)
  end

  def dynamic(str, opts={})
    text_box str, text_opts({:style => :bold}.merge(opts))
  end

  def text_opts(opts={})
    {:at => [0, ypos(opts)], :height => LINE_HEIGHT, :size => FONT_SIZE, :align => :center, :valign => :center}.merge(opts)
  end

  def ypos(opts)
    @ypos ||= TOP
    @ypos -= opts.delete(:ydelta) || LINE_SPACING
  end
  
end
