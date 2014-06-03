class Topic < ActiveRecord::Base
  belongs_to :department
  has_many :sessions, -> { where cancelled: false }, :dependent => :destroy
  has_many :documents, :dependent => :destroy
  accepts_nested_attributes_for :documents, :allow_destroy => true, :reject_if => :all_blank
  acts_as_taggable

  SURVEY_NONE = 0
  SURVEY_INTERNAL = 1
  SURVEY_EXTERNAL = 2

  def self.upcoming
    Topic.joins(sessions: :occurrences).merge(Occurrence.upcoming.order(:time)).group(:name)
  end

  def before_save
    normalize_tag_names
  end

  def deactivate!
    # if this is a brand new topic (no non-cancelled sessions), just go ahead and delete it
    if sessions.blank?
      return self.destroy!
    end
    
    self.inactive = true
    self.save!
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def upcoming_sessions
    #FIXME: lazy load
    @upcoming_sessions ||= sessions - past_sessions
  end

  def past_sessions
    #FIXME: lazy load
    @past_sessions ||= sessions.select { |s| s.started? }
  end

  def sorted_tags
    tags.sort { |a,b| a.name <=> b.name }
  end

  def sorted_tag_list
    tag_list.sort
  end
end
