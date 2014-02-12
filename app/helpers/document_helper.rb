module DocumentHelper
  def link_to_document(d, opts = {})
    url = opts.delete(:url) || d.item.url
    url_proc = opts.delete(:url_proc)
    url = url_proc.call(url) unless url_proc.nil?

    text = file_icon_image_tag(d.item.original_filename, :url_proc => url_proc)
    text << ' ' << d.friendly_name
    link_to text, url, opts
  end
end
