# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  # authentication stuff
  before_filter :authenticate
  
  # this is responible for putting the login ID of the current
  # user into session[ :user ]. It's set up to work with CAS, 
  # but should be easily tweaked to support other login systems.
  protected 
  def authenticate
    return true if session[ :user ]
    
    if session[ :cas_user ]
      session[ :user ] = session[ :cas_user ]
      return true
    else
      CASClient::Frameworks::Rails::Filter.filter( self )
    end
  end
  
  helper_method :current_user, :user_is_admin?, :user_is_instructor?
  private
  def current_user
    session[ :user ]
  end
  
  def user_is_admin?
    Admin.find( :first, :conditions => ["login = ?", current_user ] ) != nil
  end
  
  def user_is_instructor?( session )
    current_user == session.instructor.login
  end
  
end
