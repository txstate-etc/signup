class Session < ActiveRecord::Base
  belongs_to :topic
  belongs_to :site
  has_many :reservations, -> { where cancelled: false }, :dependent => :destroy
  accepts_nested_attributes_for :reservations
  has_many :occurrences, :dependent => :destroy
  accepts_nested_attributes_for :occurrences, :reject_if => :all_blank, :allow_destroy => true
  has_and_belongs_to_many :instructors, :class_name => "User", :uniq => true
  accepts_nested_attributes_for :instructors, :reject_if => lambda { |a| true }, :allow_destroy => false
  has_many :survey_responses, through: :reservations

  def initialize(attributes = nil)    
    # use our local method to add/remove instructors
    attributes.merge!(build_instructors_attributes(false, attributes.delete(:instructors_attributes))) unless attributes.nil?
    super(attributes)
  end
  
  def update(attributes)
    #FIXME: should fail on invalid user
    # use our local method to add/remove instructors
    attributes.merge!(build_instructors_attributes(true, attributes.delete(:instructors_attributes))) unless attributes.nil?
    super(attributes)
  end

  def to_param
    "#{id}-#{topic.name.parameterize}"
  end

  def time
    occurrences.first.time if occurrences.present?
  end

  def next_time
    if occurrences.present?
      o = occurrences.detect { |o| o.time > Time.now }
      return (o.nil?? time : o.time)
    end
  end

  def last_time
    occurrences.last.time if occurrences.present?
  end

  def in_past?
    last = self.last_time
    last && last < Time.now
  end

  def started?
    start = self.time
    start && start < Time.now
  end

  def in_future?
    !started?
  end

  def not_finished?
    !in_past?
  end

  def confirmed_count
    count = reservations_count
    seats && count > seats ? seats : count
  end

  def waiting_list_count
    return 0 unless seats
    count = reservations_count
    count > seats ? count - seats : 0
  end
  
  def seats_remaining
    seats - confirmed_count if seats
  end
  
  def space_is_available?
    seats ? seats_remaining > 0 : true
  end

  # Returns the list of confirmed reservations (ie those not on the waiting list)
  # in order of when they signed up. Certain logic regarding the waiting list requires
  # this order, so no sorting here.
  def confirmed_reservations
    space_is_available? ? reservations : reservations[ 0, self.seats ]
  end

  # Returns the list of confirmed reservations (ie those not on the waiting list)
  # sorted by last name. This method is appropriate for use in views, when 
  # displaying the list to users, but should not be called when
  # determining who should get promoted to the waiting list. Use confirmed_reservations for that.
  def confirmed_reservations_by_last_name
    confirmed_reservations.sort { |a,b| a.user.last_name <=> b.user.last_name }
  end
  
  def waiting_list
    space_is_available? ? [] : reservations[ self.seats, reservations.size - self.seats ]
  end
  
  def waiting_list_by_last_name
    waiting_list.sort { |a,b| a.user.last_name <=> b.user.last_name }
  end

  def reservations_by_last_name
    reservations.sort { |a,b| a.user.last_name <=> b.user.last_name }
  end

  def confirmed?(reservation)
    confirmed_reservations.include?(reservation)
  end
  
  def on_waiting_list?(reservation)
    waiting_list.include?(reservation)
  end
  
  def multiple_occurrences?
    occurrences.count > 1
  end

  def registration_period_defined?
    reg_start.present? || reg_end.present?
  end

  def in_registration_period?
    reg_start_time = self.reg_start.blank? ? self.created_at : self.reg_start
    reg_end_time = self.reg_end.blank? ? self.time : self.reg_end
    return reg_start_time <= Time.now && reg_end_time >= Time.now
  end

  def average_instructor_rating
    survey_responses.inject(0.0) { |sum, rating| sum + rating.instructor_rating } / survey_responses.size
  end
  
  def average_rating
    survey_responses.inject(0.0) { |sum, rating| sum + rating.class_rating } / survey_responses.size
  end

  def average_applicability_rating
    ratings = survey_responses.reject { |rating| rating.applicability.nil? }
    ratings.inject(0.0) { |sum, rating| sum + rating.applicability } / ratings.size
  end

  private
  def build_instructors_attributes(update, attributes)
    return {} if attributes.blank?
    
    # Example input:
    # {
    #   "1305227580344" => {"name_and_login"=>"Charles B Jones (cj32)", "_destroy"=>""},
    #               "0" => {"name_and_login"=>"Emin Saglamer (es26)",   "id"=>"30798", "_destroy"=>""},
    #               "1 "=> {"name_and_login"=>"Patrick A Smith (ps35)", "id"=>"31919", "_destroy"=>""},
    #               "2" => {"name_and_login"=>"Rori Sheffield (rp41)",  "id"=>"32014", "_destroy"=>"1"}
    # }
 
    #logger.info("in build_instructors_attributes, instructors = #{instructors.nil? ? "nil" : instructors}")
    
    ids = []
    attributes.keys.sort { |a,b| a.to_i <=> b.to_i }.each do |key|
      attr = attributes[key]
      next if attr["_destroy"] == "1"      
      if(update && attr.include?("id") && instructors.find(attr["id"]).name_and_login == attr["name_and_login"])
        ids << attr["id"]        
      elsif attr["name_and_login"].present?
        user = User.find_by_name_and_login(attr["name_and_login"])
        if user.nil? 
          @invalid_instructor = true
        else
          ids << user.id
        end        
      end
    end
    
    return { "instructor_ids" => ids }
  end

end
