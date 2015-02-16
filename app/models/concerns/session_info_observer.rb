module SessionInfoObserver
  extend ActiveSupport::Concern

  #observe :topic, :session, :reservation, :site, :occurrence, :department
  
  included do
    after_save :expire_session_info
  end

  def expire_session_info
    # Expire all view fragments when any related model is updated.
    Cashier.expire 'session-info'
    Cashier.expire self.cache_key

    case self
    when Session
      Cashier.expire *self.occurrences.map(&:cache_key)
      Cashier.expire self.topic.cache_key
      Cashier.expire self.topic.department.cache_key
    when Topic
      Cashier.expire self.department.cache_key
      Cashier.expire *self.sessions.map(&:cache_key)
      Cashier.expire *self.sessions.map(&:occurrences).flatten.map(&:cache_key)
    when Department
      Cashier.expire 'department-list'
    when Site
      Cashier.expire *self.sessions.map(&:cache_key)
      Cashier.expire *self.sessions.map(&:topic).uniq.map(&:cache_key)
      Cashier.expire *self.sessions.map{ |s| s.topic.department }.uniq.map(&:cache_key)
      Cashier.expire *self.sessions.map(&:occurrences).flatten.map(&:cache_key)
    when Reservation, Occurrence
      Cashier.expire self.session.cache_key
      Cashier.expire self.session.topic.cache_key
      Cashier.expire self.session.topic.department.cache_key
      Cashier.expire *self.session.occurrences.map(&:cache_key)
    end
     
  rescue Exception => e
    Rails.logger.error "Failed to expire tags: #{e}"   
  end

end
