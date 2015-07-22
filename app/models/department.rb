class Department < ActiveRecord::Base
  has_many :topics, -> { where inactive: false }
  has_many :permissions
  has_many :users, :through => :permissions
  accepts_nested_attributes_for :permissions, :reject_if => lambda { |p| p['name_and_login'].blank? }, :allow_destroy => true
  has_paper_trail

  scope :active, -> { where inactive: false }
  scope :by_name, -> { order :name }

  validates :name, presence: true
  validate :inactive_with_no_active_topics
  after_validation Proc.new { |d| d.name = d.name_was if d.name.blank? }, on: :update
  
  def inactive_with_no_active_topics
    errors[:base] << 'You cannot delete a department with active topics. Delete the topics first.' if inactive? && topics.present?
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def upcoming
    topics.upcoming
  end

  def deactivate!
    # if this is a brand new department (no topics, active or inactive), just go ahead and delete it
    if topics.unscope(where: :inactive).count == 0
      return self.destroy
    end
    
    self.inactive = true
    self.save
  end

  def to_csv
    CSV.generate do |csv|
      csv << Session::CSV_HEADER
      csv_rows.each { |row| csv << row }
    end
  end

  def csv_rows
    topics.map { |topic| topic.csv_rows }.flatten(1)
  end

  def survey_responses_to_csv(opts={})
    CSV.generate do |csv|
      csv << Session::SURVEY_RESPONSES_CSV_HEADER
      survey_responses_csv_rows(opts).each { |row| csv << row }
    end
  end

  def survey_responses_csv_rows(opts={})
    topics.map { |topic| topic.survey_responses_csv_rows(opts) }.flatten(1)
  end
end
