class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :reservations, -> { where(cancelled: false).includes(:session) }
  has_and_belongs_to_many :sessions, -> { where cancelled: false }

  def name
    "#{first_name} #{last_name}" 
  end

  def directory_url
    #FIXME: what if the people search has no results?
    DIRECTORY_URL_BASE.gsub(/##LOGIN##/, login) unless manual?
  end

  def title_and_department
    return title unless department.present?
    return department unless title.present?
    "#{title}, #{department}"
  end

  def upcoming_sessions
    #FIXME: lazy load
    @upcoming_sessions ||= sessions - past_sessions
  end

  def past_sessions
    #FIXME: lazy load
    @past_sessions ||= sessions.select { |s| s.started? }
  end
  
end
