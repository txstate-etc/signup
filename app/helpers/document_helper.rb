module DocumentHelper
  def link_to_document(d, opts = {})
    url = opts.delete(:url) || d.item.url
    text = file_icon_image_tag(d.item.original_filename)
    text << ' ' << d.friendly_name
    link_to text, url, opts
  end
end
