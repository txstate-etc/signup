module UsersHelper
  def link_to_user_directory(user, opts={})
    text = opts.delete(:text) || user.name
    url = user.directory_url || "mailto:#{user.email}"
    link_to text, url, opts
  end
end
