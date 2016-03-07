class CompletionCertificate < Prawn::Document
  include ApplicationHelper

  def initialize
    super(:page_layout => :landscape)
  end

  def to_pdf(reservation)

    # top border
    image "#{asset_path('certificate/topbar.jpg')}", :width => 749, :height => 20, :position => :center, :vposition => -15

    # header
    image "#{asset_path('certificate/certificate.jpg')}", :width => 688, :height => 46, :position => :center, :vposition => 28

    # main body text
    line reservation.user.name, :ypos => 425, :height => 48, :size => 48, :style => :italic, :font => 'Times-Roman'
    line 'has successfully completed the course', :ypos => 350, :color => '75746D'
    line reservation.session.topic.name, :ypos => 295, :height => 65, :size => 28, :style => :bold
    line fmt_date_range(reservation.session), :ypos => 185, :color => '75746D'
    line 'presented by', :ypos => 125, :color => '75746D'
    line reservation.session.topic.department.name, :ypos => 100, :color => '75746D'
          
    # organization logo
    logo_path = asset_path('certificate/logo.jpg')
    if logo_path
      image "#{logo_path}", :width => 139, :height => 36, :position => :center, :vposition => 485
    end

    # bottom border
    image "#{asset_path('certificate/bottombar.jpg')}", :width => 749, :height => 20, :position => :center, :vposition => 535

    render
  end

  protected

  def line(str, opts={})
    fill_color opts.delete(:color) || '000000'
    font opts.delete(:font) || 'Helvetica'
    topts = text_opts(opts)
    text_box str, topts
    # stroke_rectangle(topts[:at], topts[:width] || bounds.width, topts[:height])
  end

  def text_opts(opts={})
    {:at => [(bounds.width - 600)/2, opts.delete(:ypos)], :width => 600, :height => 20, :size => 16, :align => :center, :valign => :center, :overflow => :shrink_to_fit, :min_font_size => 12}.merge(opts)
  end

  def fmt_date_range(session)
    if session.multiple_occurrences?
      first = session.time.to_date
      last = session.last_time.to_date
      if first.year == last.year
        if first.month == last.month
          # same month
          first.strftime('%B %-e') + '-' + last.strftime('%-e, %Y')
        else
          # diff month, same year
          first.strftime('%B %-e') + '-' + last.strftime('%B %-e, %Y')
        end
      else
        # diff year
        first.strftime('%B %-e, %Y') + ' - ' + last.strftime('%B %-e, %Y')
      end
    else  
      session.last_time.strftime('%B %-e, %Y')
    end
  end
  
  def asset_path(file)
    if path = Rails.application.assets_manifest.assets[file]
      Rails.public_path.join(Rails.application.assets_manifest.directory, path)
    elsif Rails.application.assets
      Rails.application.assets.resolve(file)
    else
      nil
    end
  end
end
