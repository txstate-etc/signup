require 'ldap'

class User < ActiveRecord::Base
  has_many :permissions
  has_many :departments, :through => :permissions
  has_many :reservations, -> { where(cancelled: false).includes(:session) }
  has_and_belongs_to_many :sessions, -> { where(cancelled: false).includes(:topic) }
  has_many :topics, through: :sessions
  scope :active, -> { where inactive: false }
  scope :manual, -> { where manual: true }


  # SELECT id, name_prefix, first_name, last_name, login FROM `users`  
  # WHERE ((first_name LIKE 'a%' OR last_name LIKE 'a%' OR login LIKE 'a%')
  # AND (first_name LIKE 'b%' OR last_name LIKE 'b%' OR login LIKE 'b%'))
  def self.search(query)
    logger.debug { "in search: query = #{query}" }
    return none unless query.present?

    conditions = []
    values = []
    query.split(/\s+/).each do |word|
      conditions << "(first_name LIKE ? OR last_name LIKE ? OR login LIKE ?)"
      3.times { values << "#{word}%" }
    end
    
    logger.debug { "in search: conditions = #{conditions}" }

    User.select("id, name_prefix, first_name, last_name, login").
      where(conditions.join(" AND "), *values)
  end

  def self.directory_search(query)
    logger.debug { "in directory_search: query = #{query}" }
    return [] unless query.present?

    Ldap.search(query)
  end

  def self.extract_login(name_and_login)
    name_and_login.split(/[(|)]/).last rescue nil
  end

  def self.find_by_name_and_login(name)
    User.find_by_login(User.extract_login(name)) rescue nil
  end

  def self.find_or_lookup_by_name_and_login(name)
    User.find_or_lookup_by_login(User.extract_login(name))
  end

  def self.find_or_lookup_by_login(login)
    return nil unless login.present?
    
    user = User.find_by_login(login)
    if user.blank?
      # try to find in ldap
      begin
        user = Ldap.import_user(login)
      rescue Net::LDAP::LdapError => e
        logger.error("There was a problem importing the data from LDAP. " + e.to_s)
      end
    end
    
    user
  end

  def self.name_and_login(user)
    return user.name_and_login if user.respond_to? :name_and_login
    "#{user[:firstname]} #{user[:lastname]} (#{user[:login]})" if user.is_a? Hash
  end

  def name
    "#{first_name} #{last_name}".strip 
  end

  def directory_url
    #FIXME: what if the people search has no results?
    DIRECTORY_URL_BASE.gsub(/##LOGIN##/, login) unless manual?
  end

  def email_header
    "\"#{name}\" <#{email}>"
  end

  def name_and_login
     return nil unless name && login
     name + " (" + login + ")"
  end

  def title_and_department
    return title unless department.present?
    return department unless title.present?
    "#{title}, #{department}"
  end

  def upcoming_topics
    @upcoming_topics ||= upcoming_sessions.map { |s| s.topic }.uniq
  end

  def upcoming_sessions
    #FIXME: lazy load
    @upcoming_sessions ||= sessions - past_sessions
  end

  def past_sessions
    #FIXME: lazy load
    @past_sessions ||= sessions.select { |s| s.started? }
  end

  # return true if the user has permissions on one or more departments (and item==nil)
  # if a Department is provided, return true if he is an editor for that topic
  # if a Topic is provided, return true if he is an editor for that topic's department
  # if a Session is provided, return true if he is an editor for that session's topic's department
  def editor?(item=nil)
    defined?(@_is_editor) or @_is_editor = self.departments.present?
    return @_is_editor unless item
    return departments.include?(item) if item.is_a? Department
    return departments.include?(item.department) if item.is_a?(Topic) && !item.new_record?
    return departments.include?(item.topic.department) if item.is_a?(Session) && !item.new_record?
    false
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
