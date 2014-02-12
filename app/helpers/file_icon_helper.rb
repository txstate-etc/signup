module FileIconHelper
  def file_icon_image_tag(filename, opts={})
    file_icon = FileIcon.new(filename)
    opts = { :alt => t(:'file_icon.type', :type => (file_icon.type || filename)) }.merge opts
    image_tag(file_icon.icon_path, opts)
  end
end