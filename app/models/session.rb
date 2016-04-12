class Session < ActiveRecord::Base
  belongs_to :topic, touch: true
  belongs_to :site
  has_many :reservations, -> { order(:created_at).where(cancelled: false).includes(:user) }, :dependent => :destroy
  accepts_nested_attributes_for :reservations
  has_many :occurrences, :dependent => :destroy, after_add: :mark_dirty, after_remove: :mark_dirty
  accepts_nested_attributes_for :occurrences, :reject_if => :all_blank, :allow_destroy => true
  has_and_belongs_to_many :instructors, -> { uniq }, :class_name => "User", after_add: :mark_dirty, after_remove: :mark_dirty
  accepts_nested_attributes_for :instructors, :reject_if => lambda { |a| true }, :allow_destroy => false
  has_many :survey_responses, -> { order 'created_at DESC'}, through: :reservations
  has_paper_trail

  include SurveyAggregates
  scope :active, -> { where cancelled: false }

  validates :topic, :occurrences, presence: true
  validate :valid_registration_period
  validates :instructors, presence: true, unless: :invalid_instructor
  validates :seats, numericality: { only_integer: true, allow_nil: true }
  validate :enough_seats
  validates :location, :site, presence: true
  after_validation :reload_if_invalid

  around_update :send_update_notifications

  def invalid_instructor
    if @invalid_instructor
      errors[:instructor_id] << 'must be a valid user'
      true
    end  
  end

  def enough_seats
    old_seats = seats_was || 0
    if seats && seats < old_seats && seats < reservations.count
      errors[:seats] << 'can\'t be fewer than the number of current reservations'
    end
  end

  def valid_registration_period
    return unless registration_period_defined? && self.time

    reg_start_time = (self.reg_start.blank? ? self.created_at : self.reg_start) || Time.now
    reg_end_time = self.reg_end.blank? ? self.time : self.reg_end
    
    if reg_start_time > reg_end_time
      errors[:reg_start] << 'must be earlier than end time.'
    end
    
    if reg_end_time > self.time
      errors[:reg_end] << 'must be earlier than the session time.'
    end
  end

  def reload_if_invalid
    #bring back any instructors that were deleted
    self.reload unless (self.new_record? || self.errors.empty?)
  end

  CSV_HEADER = [ "Topic", "Session ID", "Session Date", "Session Time", "Session Cancelled", "Attendee Name", "Attendee Login", "Attendee Email", "Attendee Title", "Attendee Department", "Reservation Confirmed?", "Attended?" ]  
  
  SURVEY_RESPONSES_CSV_HEADER = [ "Topic", "Session ID", "Session Date", "Session Time", "Instructor Rating", "Content Rating", "Overall Rating", "Most Useful", "General Comments" ]  

  def self.upcoming
    Session.active.joins(:occurrences).merge(Occurrence.upcoming.order(:time))
  end

  def initialize(attributes = nil)    
    # use our local method to add/remove instructors
    attributes.merge!(build_instructors_attributes(false, attributes.delete(:instructors_attributes))) unless attributes.nil?
    super(attributes)
  end
  
  def update(attributes)
    # use our local method to add/remove instructors
    attributes.merge!(build_instructors_attributes(true, attributes.delete(:instructors_attributes))) unless attributes.nil?
    super(attributes)
  end
  
  def mark_dirty(assoc)
    self.touch if self.persisted?
    if assoc.is_a? Occurrence
      @need_update = true
    end
  end

  # around_update callback. The actual update is done in the `yield`
  def send_update_notifications
    logger.info("in send_update_notifications, @need_update = #{@need_update}")
    
    send_update = !in_past? && (
      @need_update || 
      location_changed? || 
      location_url_changed? || 
      site_id_changed? || 
      occurrences.any? { |o| o.changed? }
    )
    
    yield

    if send_update
      instructors.each do |instructor|
        ReservationMailer.update_notice_instructor( self, instructor ).deliver_later
      end
      confirmed_reservations.each do |reservation|
        ReservationMailer.update_notice( self, reservation.user ).deliver_later
      end
    end

    @need_update = false

  end

  def cancel!(custom_message = '')
    self.cancelled = true
    self.save
    if !in_past?
      instructors.each do |instructor|
        ReservationMailer.cancellation_notice_instructor( self, instructor, custom_message ).deliver_later
      end
      confirmed_reservations.each do |reservation|
        ReservationMailer.cancellation_notice( self, reservation.user, custom_message ).deliver_later
      end
    end
  end

  def to_param
    "#{id}-#{topic.name.parameterize}"
  end

  def loc_with_site
    site.present? ? "#{location} (#{site.name})" : location
  end

  def loc_with_site_and_url
    s = site.present? ? "#{location} (#{site.name})" : location
    location_url.present? ? "#{s}. #{location_url}" : s
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
    occurrences.length > 1
  end

  def registration_period_defined?
    reg_start.present? || reg_end.present?
  end

  def in_registration_period?
    reg_start_time = self.reg_start.blank? ? self.created_at : self.reg_start
    reg_end_time = self.reg_end.blank? ? self.time : self.reg_end
    return reg_start_time <= Time.now && reg_end_time >= Time.now
  end

  def instructor?(user)
    instructors.include? user
  end

  def to_cal
    calendar = RiCal.Calendar
    self.to_event.each { |event| calendar.add_subcomponent( event ) }
    return calendar.export
  end
  
  def to_event
    Rails.cache.fetch(["to_event", self.site, self.topic, self]) do
      description = "#{topic.description}\n\nInstructor(s): #{instructors.map(&:name).join(", ")}"
      if topic.tag_list.present?
        description << "\n\nTags: #{topic.sorted_tags.join(", ")}"
      end

      occurrences.map do |o|
        event = RiCal.Event 
        event.summary = topic.name
        event.description = description
        event.dtstart = o.time
        event.dtend = o.time + topic.minutes * 60
        event.url = topic.url
        event.location = loc_with_site_and_url
        event
      end
    end
  end

  def to_csv
    CSV.generate do |csv|
      csv << CSV_HEADER
      csv_rows.each { |row| csv << row }
    end
  end

  def csv_rows
    Rails.cache.fetch(["csv_rows", self.topic, self]) do
      reservations_by_last_name.map do |reservation|
        attended = ""
        if reservation.attended == Reservation::ATTENDANCE_MISSED
          attended = "MISSED"
        elsif reservation.attended == Reservation::ATTENDANCE_ATTENDED
          attended = "ATTENDED"
        end
        [ self.topic.name, self.id, self.time.strftime('%m/%d/%Y'), self.time.strftime('%I:%M %p'), self.cancelled, reservation.user.name, reservation.user.login, reservation.user.email, reservation.user.title, reservation.user.department, reservation.confirmed?, attended ]
      end
    end
  end

  def survey_responses_to_csv
    CSV.generate do |csv|
      csv << SURVEY_RESPONSES_CSV_HEADER
      survey_responses_csv_rows.each { |row| csv << row }
    end
  end

  def survey_responses_csv_rows
    Rails.cache.fetch(["survey_responses_csv_rows", self.topic, self]) do
      survey_responses.map do |sr|
        [ self.topic.name, self.id, self.time.strftime('%m/%d/%Y'), self.time.strftime('%I:%M %p'), sr.instructor_rating, sr.applicability, sr.class_rating, sr.most_useful, sr.comments ]
      end
    end
  end

  def email_all(message)
    instructors.each do |instructor|
      ReservationMailer.session_message_instructor( self, instructor, message ).deliver_later
    end
    confirmed_reservations.each do |reservation|
      ReservationMailer.session_message( self, reservation.user, message ).deliver_later
    end
  end

  def self.send_reminders( start_time, end_time, only_first_occurrence = false )
    logger.info "#{DateTime.now.strftime("%F %T")}: Sending session reminders for #{start_time.strftime("%F %T")}..."
    
    session_list = 
      Session.active.joins(:occurrences).merge(
        Occurrence.in_range(start_time, end_time).order(:time)
      )

    session_list.each do |session|
      session.reload #Force it to load in all occurrences
      # Skip sessions that have already had their first occurrence if specified
      next if only_first_occurrence && (session.time < start_time || session.time > end_time)

      # send a reminder to each student
      session.confirmed_reservations.each do |reservation|
        ReservationMailer.remind( session, reservation.user ).deliver_later
      end
      # now send one to each instructor
      session.instructors.each do |instructor|
        ReservationMailer.remind_instructor( session, instructor ).deliver_later
      end
    end
  end
  
  def self.send_followups
    logger.info "#{DateTime.now.strftime("%F %T")}: Sending followups..."
    
    session_list = 
      Session.active
        .where(survey_sent: false)
        .joins(:occurrences)
        .merge(Occurrence.in_past.order(:time))
        .group(:id)
        .readonly(false)

    session_list.each do |session|
      session.reload #Force it to load in all occurrences
      next if session.not_finished? #wait until the last occurrance
      session.instructors.each do |instructor|
        ReservationMailer.followup_instructor( session, instructor ).deliver_later
      end
      if session.topic.certificate? || session.topic.survey_type != Topic::SURVEY_NONE
        session.confirmed_reservations.each do |reservation|
          if (reservation.attended? && session.topic.certificate?) || reservation.need_survey?
            ReservationMailer.followup( reservation ).deliver_later
          end
        end
      end
      session.survey_sent = true
      session.save
    end
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
        user = User.find_or_lookup_by_name_and_login(attr["name_and_login"]) rescue nil
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
