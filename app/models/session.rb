require 'ri_cal'
require 'prawn/core'
require 'prawn/layout'

class Session < ActiveRecord::Base
  has_many :reservations
  has_many :occurrences, :dependent => :destroy
  accepts_nested_attributes_for :occurrences, :reject_if => lambda { |a| a[:time].blank? }, :allow_destroy => true
  belongs_to :topic
  has_and_belongs_to_many :instructors, :class_name => "User", :uniq => true
  accepts_nested_attributes_for :instructors, :reject_if => lambda { |a| true }, :allow_destroy => false
  validate :at_least_one_occurrence, :at_least_one_instructor, :valid_instructor
  validates_presence_of :topic_id, :location
  validates_numericality_of :seats, :only_integer => true, :allow_nil => true
  after_validation :reload_if_invalid
  accepts_nested_attributes_for :reservations  
  
  def time
    if occurrences.present?
      occurrences[0].time
    else
      nil
    end
  end

  def next_time
    if occurrences.present?
      o = occurrences.detect {|o| o.time > Time.now}
      return (o.nil?? time : o.time)
    else
      nil
    end
  end

  def last_time
    if occurrences.present?
      occurrences.last.time
    else
      nil
    end
  end

  def multiple_occurrences?
    occurrences.present? && occurrences.count > 1
  end

  def at_least_one_occurrence
    if self.occurrences.blank? || self.occurrences.all?{|o|o.marked_for_destruction?}
      self.errors.add(:occurrences, 'can\'t be blank')
    end
  end
  

  def instructor?( user )
    instructors.include? user
  end
  
  def valid_instructor
    if @invalid_instructor
      self.errors.add(:instructor_id, 'must be a valid user')
    end  
  end
  
  def at_least_one_instructor
    if self.instructors.blank? && !@invalid_instructor
      self.errors.add(:instructor_id, 'can\'t be blank')
    end
  end
  
  def reload_if_invalid
    #bring back any instructors that were deleted
    self.reload unless (self.new_record? || self.errors.empty?)
  end
  
  def to_param
    "#{id}-#{topic.name.parameterize}"
  end
  
  def initialize(attributes = nil)    
    # use our local method to add/remove instructors
    attributes.merge!(build_instructors_attributes(false, attributes.delete(:instructors_attributes))) unless attributes.nil?
    super(attributes)
  end
  
  def update_attributes(attributes)
    # use our local method to add/remove instructors
    attributes.merge!(build_instructors_attributes(true, attributes.delete(:instructors_attributes))) unless attributes.nil?
    super(attributes)
  end
  
  def before_update
    # Have to check if occurrences changed here because the dirty flag is reset by the time after_update is called.
    @occurrences_dirty = occurrences.present? && ( occurrences.changed? || occurrences.any?{ |o| o.changed? } )
    logger.info("in before_update, dirty = #{@occurrences_dirty}")
    return true
  end
  
  def after_update
    send_update = @occurrences_dirty || location_changed?
    if send_update
      confirmed_reservations.each do |reservation|
        ReservationMailer.delay.deliver_update_notice( reservation )
      end
    end
  end
  
  def cancel!(custom_message = '')
    self.cancelled = true
    self.save
    confirmed_reservations.each do |reservation|
      ReservationMailer.delay.deliver_cancellation_notice( reservation, custom_message )
    end
  end
  
  def registration_period_defined?
    reg_start.present? || reg_end.present?
  end
  
  def in_registration_period?
    return false if reg_start.present? && reg_start > Time.now
    return false if reg_end.present? && reg_end < Time.now
    return true
  end
  
  def space_is_available?
    return true if self.seats == nil
    return true if self.seats > Reservation.count( :conditions => ["session_id = ?", self.id ] )
    return false
  end
  
  def confirmed_reservations
    results = self.seats ? reservations[ 0, self.seats ] : reservations
    return results.sort { |a,b| a.user.last_name <=> b.user.last_name }
  end
  
  def seats_remaining
    seats - confirmed_reservations.size if seats
  end
  
  def waiting_list
    self.seats && confirmed_reservations.size == self.seats ? reservations[ self.seats, reservations.size - self.seats ] : []
  end
  
  def to_cal
    calendar = RiCal.Calendar
    events = self.to_event
    events.each { |event| calendar.add_subcomponent( event ) }
    return calendar.export
  end
  
  def to_event
    events = occurrences.map do |o|
      event = RiCal.Event 
      event.summary = topic.name
      event.description = topic.description + "\n\nInstructor(s): " + instructors.collect{|i| i.name}.join(", ")
      event.dtstart = o.time
      event.dtend = o.time + topic.minutes * 60
      event.url = topic.url
      event.location = location 
      event
    end
    return events
  end
  
  def self.send_reminders( start_time, end_time, only_first_occurrence = false )
    logger.info "#{DateTime.now.strftime("%F %T")}: Sending session reminders for #{start_time.strftime("%F %T")}..."
    session_list = Session.find( :all, :conditions => ['occurrences.time >= ? AND occurrences.time <= ? AND cancelled = 0', start_time, end_time ], :order => "occurrences.time", :include => :occurrences )
    session_list.each do |session|
      session.reload #Force it to load in all occurrences
      # Skip sessions that have already had their first occurrence if specified
      next if only_first_occurrence && (session.time < start_time || session.time > end_time)

      # send a reminder to each student
      session.confirmed_reservations.each do |reservation|
        ReservationMailer.delay.deliver_remind( session, reservation.user )
      end
      # now send one to each instructor
      session.instructors.each do |instructor|
        ReservationMailer.delay.deliver_remind( session, instructor )
      end
    end
  end
  
  def self.send_surveys
    logger.info "#{DateTime.now.strftime("%F %T")}: Sending survey reminders..."
    session_list = Session.all( :joins => :topic, :conditions => ['occurrences.time < ? AND survey_sent = ? AND survey_type != ? AND cancelled = ?', DateTime.now, false, Topic::SURVEY_NONE, false ], :readonly => false, :order => "occurrences.time", :include => :occurrences )
    session_list.each do |session|
      session.reload #Force it to load in all occurrences
      next if session.last_time > Time.now #wait until the last occurrance
      session.confirmed_reservations.each do |reservation|
        ReservationMailer.delay.deliver_survey_mail( reservation ) if reservation.attended != Reservation::ATTENDANCE_MISSED
      end
      session.survey_sent = true
      session.save
    end
  end
  
  def survey_responses
    Reservation.all( :joins => :survey_response, :include => :survey_response, :conditions => [ 'session_id = ?', self ] ).collect{|reservation| reservation.survey_response}
  end
  
  def average_instructor_rating
    survey_responses.inject(0.0) { |sum, rating| sum + rating.instructor_rating } / survey_responses.size
  end
  
  def average_rating
    survey_responses.inject(0.0) { |sum, rating| sum + rating.class_rating } / survey_responses.size
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
    attributes.values.each do |attr|      
      next if attr["_destroy"] == "1"      
      if(update && attr.include?("id") && instructors.find(attr["id"]).name_and_login == attr["name_and_login"])
        ids << attr["id"]        
      elsif attr["name_and_login"].present?
        user = find_instructor(attr["name_and_login"])
        if user.nil? 
          @invalid_instructor = true
        else
          ids << user.id
        end        
      end
    end
    
    return { "instructor_ids" => ids }
  end
  
  def find_instructor( name )
    return nil if name.blank?
    elements = name.split(/[(|)]/)
    if elements.size > 1
      User.find_by_login( elements.last )
    else
      User.find_by_login( elements[0] )
    end
  end
  
end
