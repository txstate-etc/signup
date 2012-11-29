class AuthenticationController < ApplicationController
  skip_before_filter :authenticate
  before_filter CASClient::Frameworks::Rails::Filter, :only => :login
  skip_before_filter :verify_authenticity_token, :only => :login
  
  def login
    if session[:cas_user] then
      session[:cas_redirect] ||= request.referrer || root_url
      redirect_to session[:cas_redirect]
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
