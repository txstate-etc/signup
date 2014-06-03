class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :authorized?
  helper_method :date_slug

  protected
  def authorized?(item=nil)
    #FIXME
    sign_in(:user, User.find(1)) unless current_user
    true
  end

  def date_slug(date=nil)
    (date || Date.today).strftime('%Y-%m-%d')
  end
end
