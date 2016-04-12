require 'ldap'

class User < ActiveRecord::Base
  has_many :auth_sessions
  has_many :permissions, dependent: :destroy
  has_many :departments, :through => :permissions
  has_many :reservations, -> { joins(:session).where(cancelled: false, sessions: { cancelled: false }) }
  has_and_belongs_to_many :sessions, -> { where(cancelled: false).includes([:topic, :occurrences]).order('occurrences.time') }
  has_many :topics, through: :departments
  has_paper_trail

  scope :active, -> { where inactive: false }
  scope :manual, -> { where manual: true }

  validate :must_not_exist, if: :manual?
  validates :login, presence: true, uniqueness: true
  validates :last_name, :email, presence: true

  attr_reader :duplicate

  def must_not_exist
    if @duplicate = User.find_or_lookup_by_login(login)
      if !@duplicate.manual?
        errors.add(:login, 'Username already exists in LDAP. Do not create manually.')
      elsif @duplicate.inactive?
        errors.add(:login, 'User was previously deleted. Contact Support to reactivate.')
      end
    end
  rescue
    errors.add(:login, 'Could not validate Username. Please try again later.')
  end

  def deactivate!
    # if this is a brand new user (no sessions or reservations), just go ahead and delete it
    if sessions.unscope(where: :cancelled).count == 0 && Reservation.where(user_id: id).count == 0
      return self.destroy!
    end
    
    self.inactive = true
    self.save!
  end

  # SELECT id, name_prefix, first_name, last_name, login FROM `users`  
  # WHERE ((first_name LIKE 'a%' OR last_name LIKE 'a%' OR login LIKE 'a%')
  # AND (first_name LIKE 'b%' OR last_name LIKE 'b%' OR login LIKE 'b%'))
  def self.search(query)
    logger.debug { "in search: query = #{query}" }
    return none unless query.present?

    conditions = []
    values = []
    query.split(/\s+/).each do |word|
      conditions << "(first_name LIKE ? OR last_name LIKE ? OR login LIKE ? OR email LIKE ?)"
      4.times { values << "#{word}%" }
    end
    
    logger.debug { "in search: conditions = #{conditions}" }

    User.select("id, name_prefix, first_name, last_name, login").
        where(conditions.join(" AND "), *values)
  end

  def self.directory_search(query)
    logger.debug { "in directory_search: query = #{query}" }
    return [] unless query.present?

    begin
      Ldap.search(query)
    rescue Ldap::ConnectError, Net::LDAP::LdapError => e
      logger.error("There was a problem importing the data from LDAP. " + e.to_s)
      return []
    end
  end

  def self.extract_login(name_and_login)
    name_and_login.split(/[(|)]/).last rescue nil
  end

  def self.find_or_lookup_by_id(id)
    User.lookup(User.find(id))
  end

  def self.find_or_lookup_by_name_and_login(name)
    User.find_or_lookup_by_login(User.extract_login(name))
  end

  def self.find_or_lookup_by_login(login)
    return nil unless login.present?
    User.lookup(login.is_a?(User) ? login : (User.find_by_login(login) || login))
  end
  
  def self.lookup(user)
    if !user.is_a?(User) || user.need_update?
      # try to find in ldap
      begin
        login = user.is_a?(User) ? user.login : user
        ldap_user = Ldap.import_user(login)
        user = ldap_user if ldap_user
      rescue Ldap::ConnectError, Net::LDAP::LdapError => e
        logger.error("There was a problem importing the data from LDAP. " + e.to_s)
        raise unless user.is_a?(User)
      end
    end
    
    user.is_a?(User) ? user : nil
  end

  def self.name_and_login(user)
    return user.name_and_login if user.respond_to? :name_and_login
    "#{user[:firstname]} #{user[:lastname]} (#{user[:login]})" if user.is_a? Hash
  end

  def name
    dr = name_prefix.strip.sub(/([^.])$/) { $1 + '.' } if name_prefix =~ /dr|doc/i  
    "#{dr} #{first_name} #{last_name}".strip 
  end

  def directory_url
    return unless defined? DIRECTORY_URL_BASE

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

  def upcoming_sessions
    @upcoming_sessions ||= sessions - past_sessions
  end

  def past_sessions
    @past_sessions ||= sessions.select { |s| s.started? }.reverse
  end

  def need_update? 
    !self.manual? && self.updated_at < 5.minutes.ago
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


  def authorized?(item=nil)
    
    # Admins can do anything
    return true if self.admin?
    
    # Editors can only edit things in their own departments.
    # Instructors can edit sessions they are the instructor of.
    # Regular users (i.e., students) can't do anything.
    return false if !self.editor? && !self.instructor?
    
    # Return true if we are just being asked about general editing permissions.
    return true if item.nil?

    # Only admins can edit departments.
    return false if item.is_a? Department
    
    # Editors can create and edit topics in their department.
    # Instructors cannot edit topics.
    if item.is_a? Topic 
      return self.editor? if item.new_record? && item.department.blank?
      return self.departments.include?(item.department)
    end
    
    # Editors can create and edit sessions for topics in their department.
    # Instructors can edit sessions they are the instructor of.
    if item.is_a? Session 
      return self.editor? if item.new_record? && item.topic.blank?
      return self.departments.include?(item.topic.department) || (!item.new_record? && item.instructor?( self ))
    end
    
    # Editors can create and edit reservations for topics in their department.
    # Instructors can create and edit reservations for sessions they are the instructor of.
    if item.is_a? Reservation 
      return self.departments.include?(item.session.topic.department) || item.session.instructor?( self )
    end
    
    # Editors and Instructors can create new users (e.g., for Instructors who are not in the system).
    # Only admins can edit them.
    if item.is_a? User
      return item.new_record?
    end
    
    # If item is an array of items, recursively call ourself on each one.
    # Only return true if they are all authorized.
    if item.is_a?(Array) && item.size > 0
      return item.all? { |i| authorized? i }
    end

    # Default deny.
    return false
  end
end
