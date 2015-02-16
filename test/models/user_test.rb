require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users
  
  test "Make sure users without first names work" do
    assert_equal users( :instructor1 ).name, "Instructor1"
  end

  test "Make sure name_and_login synthesized attribute works" do
    assert_equal users( :plainuser1 ).name_and_login, "Plain User1 (pu12345)"
  end
  
  test "Admins can do anything" do
    user = users( :admin1 )
    assert user.authorized?
    assert user.authorized? nil
    assert user.authorized? "any argument, doesn't matter"
    assert user.authorized? Topic.new
    assert user.authorized? Session.new
    assert user.authorized? Department.new
    assert user.authorized? Reservation.new
    assert user.authorized? User.new
    Topic.all.each { |t| assert user.authorized?(t), "Admin NOT authorized for topic: #{t.name}" }
    Session.all.each { |s| assert user.authorized?(s), "Admin NOT authorized for session: #{s.topic.name}, #{s.time}" }
    Reservation.all.each { |r| assert user.authorized?(r), "Admin NOT authorized for reservation: #{r.user.name}, #{r.session.topic.name}, #{r.session.time}" }
    Department.all.each { |d| assert user.authorized?(d), "Admin NOT authorized for department: #{d.name}" }
    User.all.each { |u| assert user.authorized?(u), "Admin NOT authorized for user: #{u.name}" }
  end

  test "Normal users cannot do anything" do
    user = users( :plainuser1 )
    assert !user.authorized?
    assert !user.authorized?(nil)
    assert !user.authorized?("any argument, doesn't matter")
    assert !user.authorized?(Topic.new)
    assert !user.authorized?(Session.new)
    assert !user.authorized?(Department.new)
    assert !user.authorized?(Reservation.new) # Of course, normal users CAN create reservations, but `authorized?` is not called then 
    assert !user.authorized?(User.new)
    Topic.all.each { |t| assert !user.authorized?(t), "plainuser1 authorized for topic: #{t.name}" }
    Session.all.each { |s| assert !user.authorized?(s), "plainuser1 authorized for session: #{s.topic.name}, #{s.time}" }
    Reservation.all.each { |r| assert !user.authorized?(r), "plainuser1 authorized for reservation: #{r.user.name}, #{r.session.topic.name}, #{r.session.time}" }
    Department.all.each { |d| assert !user.authorized?(d), "plainuser1 authorized for department: #{d.name}" }
    User.all.each { |u| assert !user.authorized?(u), "plainuser1 authorized for user: #{u.name}" }
  end
  
  test "Editors can create and edit topics in their departments" do
    user = users( :editor1 )
    assert user.authorized?
    assert user.authorized?(nil)
    assert !user.authorized?("unexpected argument")
    assert user.authorized?(Topic.new)
    assert user.authorized?(Topic.new(:department => departments(:its)))
    assert !user.authorized?(Topic.new(:department => departments(:tr)))
    assert user.authorized?(Session.new(:topic => topics(:gato)))
    assert !user.authorized?(Session.new(:topic => topics(:no_survey_topic)))
    assert !user.authorized?(Department.new)
    assert user.authorized?(User.new)
    
    Topic.all.each do |t| 
      if t.department == departments(:its)
        assert user.authorized?(t), "editor1 NOT authorized for topic: #{t.name}"
      else
        assert !user.authorized?(t), "editor1 authorized for topic: #{t.name}"
      end
    end
    
    Session.all.each do |s| 
      if s.topic.department == departments(:its) || s == sessions(:topic_with_attached_documents)
        assert user.authorized?(s), "editor1 NOT authorized for session: #{s.topic.name}, #{s.time}"
      else
        assert !user.authorized?(s), "editor1 authorized for session: #{s.topic.name}, #{s.time}"
      end
    end

    Reservation.all.each do |r| 
      if r.session.topic.department == departments(:its) || r.session == sessions(:topic_with_attached_documents)
        assert user.authorized?(r), "editor1 NOT authorized for reservation: #{r.user.name}, #{r.session.topic.name}, #{r.session.time}"
      else
        assert !user.authorized?(r), "editor1 authorized for reservation: #{r.user.name}, #{r.session.topic.name}, #{r.session.time}"
      end
    end

    Department.all.each { |d| assert !user.authorized?(d), "editor1 authorized for department: #{d.name}" }
    User.all.each { |u| assert !user.authorized?(u), "editor1 authorized for user: #{u.name}" }
  end

  test "Instructors can only edit sessions that they teach" do
    user = users( :instructor2 )
    assert user.authorized?
    assert user.authorized?(nil)
    assert !user.authorized?("unexpected argument")
    assert !user.authorized?(Topic.new)
    assert !user.authorized?(Topic.new(:department => departments(:its)))
    assert !user.authorized?(Topic.new(:department => departments(:tr)))
    assert !user.authorized?(Session.new)
    assert !user.authorized?(Session.new(:topic => topics(:tracs)))
    assert !user.authorized?(Session.new(:instructors => [user]))
    assert !user.authorized?(Department.new)
    assert user.authorized?(User.new)
    
    Topic.all.each { |t| assert !user.authorized?(t), "instructor2 authorized for topic: #{t.name}" }
    
    allowed_sessions = [:tracs, :tracs_tiny, :tracs_tiny_full, :tracs_multiple_instructors]
    allowed_sessions.each do |s|
      assert user.authorized?(sessions(s)), "instructor2 NOT authorized for session: #{s}"
    end
    
    allowed_sessions = allowed_sessions.map { |s| sessions(s) }
    (Session.all - allowed_sessions).each do |s| 
      assert !user.authorized?(s), "instructor2 authorized for session: #{s.topic.name}, #{s.time}"
    end

    allowed_sessions = allowed_sessions.map(&:id)
    Reservation.all.each do |r| 
      if allowed_sessions.include?(r.session.id)
        assert user.authorized?(r), "instructor2 NOT authorized for reservation: #{r.user.name}, #{r.session.topic.name}, #{r.session.time}"
      else
        assert !user.authorized?(r), "instructor2 authorized for reservation: #{r.user.name}, #{r.session.topic.name}, #{r.session.time}"
      end
    end

    Department.all.each { |d| assert !user.authorized?(d), "instructor2 authorized for department: #{d.name}" }
    User.all.each { |u| assert !user.authorized?(u), "instructor2 authorized for user: #{u.name}" }
  end
    
  test "Editors and Instructors are identified correctly" do
    assert !users( :plainuser1 ).admin?
    assert !users( :plainuser1 ).editor?
    assert !users( :plainuser1 ).instructor?

    assert !users( :instructor1 ).admin?
    assert !users( :instructor1 ).editor?
    assert users( :instructor1 ).instructor?

    assert !users( :editor1 ).admin?
    assert users( :editor1 ).editor?
    assert users( :editor1 ).instructor?

    assert !users( :editor2 ).admin?
    assert users( :editor2 ).editor?
    assert !users( :editor2 ).instructor?
  end

  test "Editors are identified with arguments" do
    assert !users( :plainuser1 ).editor?(nil)
    assert !users( :plainuser1 ).editor?("arbitrary object")
    assert !users( :plainuser1 ).editor?(topics(:gato))
    assert !users( :plainuser1 ).editor?(departments(:its))
    assert !users( :plainuser1 ).editor?(sessions(:gato))

    assert !users( :instructor1 ).editor?(nil)
    assert !users( :instructor1 ).editor?("arbitrary object")
    assert !users( :instructor1 ).editor?(topics(:gato))
    assert !users( :instructor1 ).editor?(departments(:its))
    assert !users( :instructor1 ).editor?(sessions(:gato))
    
    assert users( :editor1 ).editor?(nil)
    assert !users( :editor1 ).editor?("arbitrary object")
    assert users( :editor1 ).editor?(topics(:gato))
    assert !users( :editor1 ).editor?(topics(:no_survey_topic))
    assert users( :editor1 ).editor?(departments(:its))
    assert !users( :editor1 ).editor?(departments(:tr))
    assert users( :editor1 ).editor?(sessions(:gato))
    assert !users( :editor1 ).editor?(sessions(:no_survey_topic_past))
  end

  test "Normal Users have no Intructor sessions" do
    user = users( :plainuser1 )
    assert user.sessions.blank?
    assert user.upcoming_sessions.blank?
    assert user.past_sessions.blank?
  end

  test "Editors have no Intructor sessions unless they are also instructors" do
    user = users( :editor2 )
    assert user.sessions.blank?
    assert user.upcoming_sessions.blank?
    assert user.past_sessions.blank?

    user = users( :editor1 )
    assert_equal 1, user.sessions.size
    assert_equal 0, user.upcoming_sessions.size
    assert_equal 1, user.past_sessions.size
    assert_equal sessions(:topic_with_attached_documents), user.past_sessions.first
  end

  test "Instructors have Intructor sessions" do
    user = users( :instructor1 )
    assert_equal 14, user.sessions.size
    assert_equal 6, user.upcoming_sessions.size
    assert_equal 8, user.past_sessions.size
    assert_equal sessions(:gato), user.upcoming_sessions.first
    assert_equal sessions(:no_survey_topic_past), user.past_sessions.first
  end

end
