class Department < ActiveRecord::Base
  has_many :topics, :conditions => { :inactive => false }
  has_many :permissions
  has_many :users, :through => :permissions
  accepts_nested_attributes_for :permissions, :reject_if => lambda { |p| p['name_and_login'].blank? }, :allow_destroy => true
  default_scope :order => "name"
  named_scope :active, :conditions => { :inactive => false }
  has_paper_trail
  
  validate :inactive_with_no_active_topics
  validates_presence_of :name
  
  def inactive_with_no_active_topics
    errors.add_to_base("You cannot delete a department with active topics. Delete the topics first.") if inactive? && topics.present?
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end
  
  def <=>(other)
    self.name <=> other.name
  end
  
  def upcoming
    Topic.find(:all, :conditions => ["department_id = ? AND occurrences.time > ? AND sessions.cancelled = false", self.id, Time.now], :joins => {:sessions => :occurrences}, :group => :name)
  end
  
  def deactivate!
    # if this is a brand new department (no topics, active or inactive), just go ahead and delete it
    if Topic.count(:all, :conditions => [ 'department_id = ?', self.id ]) == 0
      return self.destroy
    end
    
    self.inactive = true
    self.save
  end
  
  def to_csv
    FasterCSV.generate do |csv|
      csv << Session::CSV_HEADER
      csv_rows(csv)
    end
  end

  def csv_rows(csv)
    topics.each do |topic|
      topic.csv_rows(csv)
    end
  end

end
