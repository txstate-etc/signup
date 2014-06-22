class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user
  helper_method :auth_user
  helper_method :authorized?
  helper_method :date_slug

  # this is responible for putting the login ID of the current
  # user into session[ :user ]. It's set up to work with OmniAuth, 
  # which should be configured in config/initializers/omniauth.rb
  protected 
  def authenticate
    return true if current_user && current_user.credentials == session[:credentials]

    # redirect to omniauth provider
    redirect_to '/auth/cas' 
    return false    
  end

  def authorized?(item=nil)
    #FIXME
    current_user.present?
  end

  def date_slug(date=nil)
    (date || Date.today).strftime('%Y-%m-%d')
  end

  private
  def current_user
    @_current_user ||= begin
      session[:user].present? && 
      session[:credentials].present? && 
      User.find_by_id_and_credentials(session[ :user ], session[:credentials])
    end
  end

  def auth_user
    session[ :auth_user ]
  end
  
end
