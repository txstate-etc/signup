class AuthSessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :single_sign_out
  
  def create
    session[:credentials] = auth_credentials[:ticket]
    user = User.find_or_lookup_by_login(auth_user) rescue nil

    if user.blank?
      session[:auth_user] = auth_user
      flash[:alert] = "Oops! We could not log you in. If you just received your login ID, you may need to wait 24 hours before it's available."
      redirect_to root_url and return
    end
    
    session[:user] = user.id
    AuthSession.create! credentials: session[:credentials], user_id: session[:user]

    redirect_to (origin_url || request.referrer || root_url)
  end

  # Can't use turbolinks with this:
  # http://www.davidlowry.co.uk/562/creating-download-click-tracker-rails-4-also-run-ins-turbolinks/
  # https://github.com/rails/turbolinks/pull/260
  def destroy
    clear_credentials(session[:credentials])
    reset_session
    redirect_to "#{LOGOUT_URL}?url=#{CGI.escape(root_url)}"
  end

  def single_sign_out
    clear_credentials(params[:session_index])
    render nothing: true
  end

  protected

  def clear_credentials(credentials)
    # destroy ticket<->session mapping
    AuthSession.find_by_credentials(credentials).try(:'destroy!')
  end

  def auth_credentials
    auth_hash[:credentials]
  end

  def auth_user
    auth_hash[:uid]
  end

  def origin_url
    request.params['url'] || request.env['omniauth.origin']
  end

  def auth_hash
    request.env['omniauth.auth']
  end

end
