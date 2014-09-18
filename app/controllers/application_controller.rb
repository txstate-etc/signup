class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  GOOGLE_ANALYTICS_URL = URI('http://www.google-analytics.com/collect')

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

  def send_analytics(opts = {})
    tracking_id = Rails.application.secrets.google_analytics_tracking_id
    if tracking_id.present?
      # random, anonymous client id; lifetime for the current session
      @client_id ||= (session[:ga_client_id] ||= SecureRandom.uuid)

      # Default to 'pageview' track type. See the docs for other types/params:
      # https://developers.google.com/analytics/devguides/collection/protocol/v1/reference
      params = {
        'v' => 1, # protocol version
        'tid' => tracking_id, # tracking/web_property id
        'cid' => @client_id, # unique client id
        't' => 'pageview',
        'dh' => request.headers['HTTP_HOST'],
        'dp' => request.headers['REQUEST_URI'],
        'dt' => @page_title,
        'ua' => request.headers['HTTP_USER_AGENT']
      }

      Net::HTTP.post_form(GOOGLE_ANALYTICS_URL, params.merge(opts))
    end
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
