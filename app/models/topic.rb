require 'fastercsv'

class Topic < ActiveRecord::Base
  SURVEY_NONE = 0
  SURVEY_INTERNAL = 1
  SURVEY_EXTERNAL = 2

  belongs_to :department
  has_many :sessions, :dependent => :destroy
  has_many :documents, :dependent => :destroy
  accepts_nested_attributes_for :documents, :allow_destroy => true, :reject_if => lambda { |t| t['item'].nil? }
  validates_presence_of :name, :description, :minutes, :department
  validates_associated :department
  validates_presence_of :survey_url, :if => Proc.new{ |topic| topic.survey_type == SURVEY_EXTERNAL }, :message => "must be specified to use an external survey."
  validate :inactive_with_no_upcoming_sessions
  default_scope :order => 'name'
  named_scope :active, :conditions => { :inactive => false }
  has_paper_trail
  acts_as_taggable

  def inactive_with_no_upcoming_sessions
    errors.add_to_base("You cannot delete a topic with upcoming sessions. Cancel the sessions first.") if inactive? && upcoming_sessions.present?
  end
  
  def after_validation
    if !self.errors.empty?
      # delete any documents that were just uploaded, since they will have to be uploaded again
      documents.delete_if { |d| d.destroy if d.new_record? }
    end
    true
  end

  def before_update
    # Coerce tag_list to be all lower-case with no special chars
    self.tag_list = self.tag_list.join(' ').split(/\s*[,;]\s*|\s+/).map {|s| s.titleize.parameterize.to_s}
  end

  def self.upcoming_tagged_with(tag)
    Topic.tagged_with(tag).find( :all, :conditions => [ "topics.id IN ( select topic_id from sessions, occurrences where sessions.id = occurrences.session_id AND occurrences.time > ? AND cancelled = false )", Time.now ] )
  end

  def self.upcoming
    Topic.find( :all, :conditions => [ "topics.id IN ( select topic_id from sessions, occurrences where sessions.id = occurrences.session_id AND occurrences.time > ? AND cancelled = false )", Time.now ] )
  end
  
  def self.by_instructor(user, upcoming=false)
    sub_select = "select topic_id from sessions, sessions_users, occurrences where sessions.id = sessions_users.session_id AND sessions_users.user_id = ? AND cancelled = false"
    sub_select << " AND sessions.id = occurrences.session_id AND occurrences.time > ?" if upcoming
    conditions = [" topics.id IN ( #{sub_select} )", user.id]
    conditions << Time.now if upcoming
    Topic.find( :all, :conditions => conditions )
  end
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
  
  def <=>(other)
    self.name <=> other.name
  end
  
  def sorted_tags
    tags.sort { |a,b| a.name <=> b.name }
  end

  def sorted_tag_list
    tag_list.sort
  end

  def upcoming_sessions
    @_upcoming_sessions ||= sessions.find( :all, :conditions => [ "cancelled = false AND sessions.id NOT IN (SELECT session_id FROM occurrences WHERE occurrences.time <= ?)", Time.now ], :order => "occurrences.time", :include => :occurrences )
  end
  
  def past_sessions
    @_past_sessions ||= sessions.find( :all, :conditions => [ "occurrences.time < ? AND cancelled = false", Time.now ], :order => "occurrences.time", :include => :occurrences )
  end
  
  def deactivate!
    # if this is a brand new topic (no non-cancelled sessions), just go ahead and delete it
    if upcoming_sessions.blank? && past_sessions.blank?
      return self.destroy
    end
    
    self.inactive = true
    self.save
  end
  
  def self.to_csv(topics)
    FasterCSV.generate do |csv|
      csv << Session::CSV_HEADER
      topics.each do |topic|
        topic.csv_rows(csv)
      end
    end
  end

  def to_csv
    FasterCSV.generate do |csv|
      csv << Session::CSV_HEADER
      csv_rows(csv)
    end
  end
  
  def csv_rows(csv)
    sessions.each do |session|
      session.csv_rows(csv)
    end
  end    

  def survey_responses
    Reservation.all(:joins => [ :survey_response, :session ], 
      :include => [ :survey_response, :session ], 
      :conditions => [ 'topic_id = ?', self ] ).collect{|reservation| reservation.survey_response}.sort{|a,b| b.created_at <=> a.created_at}
  end
  
  def average_instructor_rating
    survey_responses.inject(0.0) { |sum, rating| sum + rating.instructor_rating } / survey_responses.size
  end
  
  def average_rating
    survey_responses.inject(0.0) { |sum, rating| sum + rating.class_rating } / survey_responses.size
  end
  
  def average_applicability_rating
    ratings = survey_responses.reject { |rating| rating.applicability.nil? }
    ratings.inject(0.0) { |sum, rating| sum +rating.applicability } / ratings.size
  end
end
