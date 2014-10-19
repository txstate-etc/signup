class AuthenticationController < ApplicationController

  def create
    session[:auth_user] = auth_user
    session[:credentials] = auth_credentials[:ticket]
    user = User.find_or_lookup_by_login(auth_user)

    if user.blank?
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
    redirect_to "#{CAS_LOGOUT_URL}?url=#{CGI.escape(root_url)}"
  end

  # FIXME: make sure to test this on staging
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
