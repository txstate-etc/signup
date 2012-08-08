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
    Topic.all.each { |t| assert user.authorized?(t), "Admin NOT authorized for topic: #{t.name}" }
    Session.all.each { |s| assert user.authorized?(s), "Admin NOT authorized for session: #{s.topic.name}, #{s.time}" }
    Reservation.all.each { |r| assert user.authorized?(r), "Admin NOT authorized for reservation: #{r.user.name}, #{r.session.topic.name}, #{r.session.time}" }
    Department.all.each { |d| assert user.authorized?(d), "Admin NOT authorized for department: #{d.name}" }
  end

  test "Normal users cannot do anything" do
    user = users( :plainuser1 )
    assert !user.authorized?
    assert !user.authorized?(nil)
    assert !user.authorized?("any argument, doesn't matter")
    assert !user.authorized?(Topic.new)
    assert !user.authorized?(Session.new)
    assert !user.authorized?(Department.new)
    Topic.all.each { |t| assert !user.authorized?(t), "plainuser1 authorized for topic: #{t.name}" }
    Session.all.each { |s| assert !user.authorized?(s), "plainuser1 authorized for session: #{s.topic.name}, #{s.time}" }
    Reservation.all.each { |r| assert !user.authorized?(r), "plainuser1 authorized for reservation: #{r.user.name}, #{r.session.topic.name}, #{r.session.time}" }
    Department.all.each { |d| assert !user.authorized?(d), "plainuser1 authorized for department: #{d.name}" }
  end
  
  test "Editors can create and edit topics in their departments" do
    user = users( :editor1 )
    assert user.authorized?
    assert user.authorized?(nil)
    assert !user.authorized?("unexpected argument")
    assert user.authorized?(Topic.new)
    assert user.authorized?(Session.new(:topic => topics(:gato)))
    assert !user.authorized?(Department.new)
    
    Topic.all.each do |t| 
      if t.department == departments(:its)
        assert user.authorized?(t), "editor1 NOT authorized for topic: #{t.name}"
      else
        assert !user.authorized?(t), "editor1 authorized for topic: #{t.name}"
      end
    end
    
    Session.all.each do |s| 
      if s.topic.department == departments(:its)
        assert user.authorized?(s), "editor1 NOT authorized for session: #{s.topic.name}, #{s.time}"
      else
        assert !user.authorized?(s), "editor1 authorized for session: #{s.topic.name}, #{s.time}"
      end
    end

    Reservation.all.each do |r| 
      if r.session.topic.department == departments(:its)
        assert user.authorized?(r), "editor1 NOT authorized for reservation: #{r.user.name}, #{r.session.topic.name}, #{r.session.time}"
      else
        assert !user.authorized?(r), "editor1 authorized for reservation: #{r.user.name}, #{r.session.topic.name}, #{r.session.time}"
      end
    end

    Department.all.each { |d| assert !user.authorized?(d), "editor1 authorized for department: #{d.name}" }
  end

  test "Instructors can only edit sessions that they teach" do
    user = users( :instructor2 )
    assert user.authorized?
    assert user.authorized?(nil)
    assert !user.authorized?("unexpected argument")
    assert !user.authorized?(Topic.new)
    assert !user.authorized?(Session.new(:topic => topics(:tracs)))
    assert !user.authorized?(Department.new)
    
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
        assert user.authorized?(r), "editor1 NOT authorized for reservation: #{r.user.name}, #{r.session.topic.name}, #{r.session.time}"
      else
        assert !user.authorized?(r), "editor1 authorized for reservation: #{r.user.name}, #{r.session.topic.name}, #{r.session.time}"
      end
    end

    Department.all.each { |d| assert !user.authorized?(d), "editor1 authorized for department: #{d.name}" }
  end
    
    
end
