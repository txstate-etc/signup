require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  fixtures :topics, :departments
  
  def test_upcoming_sessions
    upcoming_tracs = Topic.find( topics( :tracs ) ).upcoming_sessions
    assert_equal( upcoming_tracs.length, 4, "TRACS should have 4 upcoming session")
    
    upcoming_gato = Topic.find( topics( :gato ) ).upcoming_sessions
    assert_equal( upcoming_gato.length, 4, "Gato should have 4 upcoming sessions")
  end
  
  test "Verify that past sessions are computed correctly" do
    past_tracs = topics( :tracs ).past_sessions
    assert_equal( past_tracs.length, 1 )
    
    past_gato = topics( :gato ).past_sessions
    assert_equal( past_gato.length, 2 )
  end
  
  test "Verify CSV" do
    csv = topics( :tracs ).to_csv
    assert_equal 5, csv.split(/\n/).size, "CSV for TRACS should have 5 lines"
    
    csv = topics( :gato ).to_csv
    assert_equal 10, csv.split(/\n/).size, "CSV for Gato should have 10 lines"
  end
  
  test "Should find survey responses correctly" do
    assert_equal 2, topics( :gato ).survey_responses.size
    assert_equal 0, topics( :tracs ).survey_responses.size
  end

  test "Should compute average ratings correctly" do
    assert_equal 3.0, topics( :gato ).average_rating
    assert_equal 3.0, topics( :gato ).average_instructor_rating
  end
  
  test "Verify relationship to Departments" do
    assert_equal departments( :its ), topics( :gato ).department
  end
end
