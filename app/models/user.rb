class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :reservations, -> { where(cancelled: false).includes(:session) }
  has_and_belongs_to_many :sessions, -> { where cancelled: false }

  def name
    "#{first_name} #{last_name}" 
  end

  def directory_url
    #FIXME: what if the people search has no results?
    DIRECTORY_URL_BASE.gsub(/##LOGIN##/, login) unless manual?
  end

  def title_and_department
    return title unless department.present?
    return department unless title.present?
    "#{title}, #{department}"
  end

  def upcoming_sessions
    #FIXME: lazy load
    @upcoming_sessions ||= sessions - past_sessions
  end

  def past_sessions
    #FIXME: lazy load
    @past_sessions ||= sessions.select { |s| s.started? }
  end
  
  # return true if the user is an instructor for any session (even in the past) [and item==nil]
  # if a Topic is provided, return true if he is an instructor for any session for that topic
  # if a Session is provided, return true if he is an instructor for that session
  def instructor?(item=nil)
    defined?(@_is_instructor) or @_is_instructor = self.sessions.present?
    return @_is_instructor unless item
    return sessions.any? { |s| s.topic_id == item.id } if item.is_a? Topic
    return sessions.include?(item) if item.is_a? Session
    false
  end
end
