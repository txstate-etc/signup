module FileIconHelper
  def file_icon_image_tag(filename, opts={})
    file_icon = FileIcon.new(filename)

    url = opts.delete(:url) || file_icon.icon_path
    url_proc = opts.delete(:url_proc)
    url = url_proc.call(url) unless url_proc.nil? 

    opts = { :alt => t(:'file_icon.type', :type => (file_icon.type || filename)) }.merge opts
    image_tag(url, opts)
  end
end
