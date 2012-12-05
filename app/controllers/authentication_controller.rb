class AuthenticationController < ApplicationController
  skip_before_filter :authenticate
  skip_before_filter :verify_authenticity_token, :only => :login
  
  def login
    session[:cas_redirect] ||= request.referrer || root_url
    if authenticate then
      redirect_to session[:cas_redirect]
      session[:cas_redirect] = nil
    end
  end

  def logout
    if session[:cas_user] then
      CASClient::Frameworks::Rails::Filter.logout(self, root_url)
    else
      redirect_to root_url
    end
  end

end
