class SessionInfoObserver < ActiveRecord::Observer
  observe :topic, :session, :reservation, :site, :occurrence
 
  def after_save(record)
    # Expire all view fragments when any related model is updated.
    Cashier.expire 'session-info'
    Cashier.expire record.cache_key
  end

end
