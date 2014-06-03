class Session < ActiveRecord::Base
  belongs_to :topic
  belongs_to :site
  has_many :reservations, -> { where cancelled: false }, :dependent => :destroy
  has_many :occurrences, :dependent => :destroy
  
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

end
