# lib/tasks/populate.rake
# Uses the Populator and Faker gems to generate bulk test data
namespace :db do
  desc "Fill database with users"
  task :populate_users => :environment do
    require 'populator'
    require 'faker'
    
    User.populate 100 do |person|
      person.name = Faker::Name.name
      person.login = person.name[0..2] + (10..100).to_a.rand.to_s
      person.email = person.name.gsub(" ", ".") + '@dev.nul'
      person.admin = false
      person.instructor = false;
    end
  end

  desc "Fill database with reservations"
  task :populate_reservations => :environment do
    require 'populator'
    
    Session.populate 1 do |session|
      session.time = 5.days.from_now
      session.instructor_id = User.find_all_by_instructor( true )
      session.topic_id = Topic.all
      session.location = "Alkek 155"
      session.cancelled = false
      Reservation.populate 35 do |reservation|
        reservation.user_id = User.all
        reservation.session_id = session.id
      end
    end
  end


end

