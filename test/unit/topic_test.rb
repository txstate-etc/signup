require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  fixtures :topics
  
  def test_upcoming_sessions
    upcoming_tracs = Topic.find( topics( :tracs ) ).upcoming_sessions
    assert_equal( upcoming_tracs.length, 3, "TRACS should have 3 upcoming session")
    
    upcoming_gato = Topic.find( topics( :gato ) ).upcoming_sessions
    assert_equal( upcoming_gato.length, 4, "Gato should have 4 upcoming sessions")
  end
  
  test "Verify CSV" do
    csv = topics( :tracs ).to_csv
    assert_equal 4, csv.split(/\n/).size, "CSV for TRACS should have 3 lines"
    
    csv = topics( :gato ).to_csv
    assert_equal 10, csv.split(/\n/).size, "CSV for Gato should have 10 lines"
  end
  
  test "Should find survey responses correctly" do
    assert_equal 2, topics( :gato ).survey_responses.size
    assert_equal 0, topics( :tracs ).survey_responses.size
  end

end
