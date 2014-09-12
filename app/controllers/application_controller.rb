class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user
  helper_method :auth_user
  helper_method :authorized?
  helper_method :login_path
  helper_method :date_slug

  # this is responible for putting the login ID of the current
  # user into session[ :user ]. It's set up to work with OmniAuth, 
  # which should be configured in config/initializers/omniauth.rb
  protected 
  def authenticate
    #FIXME: tying db credentials to cookie credentials means users can't log in with multiple browsers simultaneously
    return true if current_user && current_user.credentials == session[:credentials]

    # redirect to omniauth provider
    redirect_to login_path
    return false    
  end

  def authorized?(item=nil)
    current_user && current_user.authorized?(item)
  end

  def login_path
    '/auth/cas'
  end

 def date_slug(date=nil)
    (date || Date.today).strftime('%Y-%m-%d')
  end

  def send_csv(csv, filename)
    send_data csv,
          type: 'text/csv; charset=iso-8859-1; header=present',
          filename: "#{filename.to_param}.csv"
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
