class SessionInfoObserver < ActiveRecord::Observer
  observe :topic, :session, :reservation, :site, :occurrence, :department
 
  def after_save(record)
    # Expire all view fragments when any related model is updated.
    Cashier.expire 'session-info'
    Cashier.expire record.cache_key

    case record
    when Session
      Cashier.expire *record.occurrences.map(&:cache_key)
      Cashier.expire record.topic.cache_key
    when Topic
      Cashier.expire *record.sessions.map(&:cache_key)
      Cashier.expire *record.sessions.map(&:occurrences).flatten.map(&:cache_key)
    when Site
      Cashier.expire *record.sessions.map(&:cache_key)
      Cashier.expire *record.sessions.map(&:topic).uniq.map(&:cache_key)
      Cashier.expire *record.sessions.map(&:occurrences).flatten.map(&:cache_key)
    when Reservation, Occurrence
      Cashier.expire record.session.cache_key
      Cashier.expire record.session.topic.cache_key
      Cashier.expire *record.session.occurrences.map(&:cache_key)
    end
        
  end

end
