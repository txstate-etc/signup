require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  fixtures :topics
  
  def test_upcoming_sessions
    upcoming_tracs = Topic.find( topics( :tracs ) ).upcoming_sessions
    assert_equal( upcoming_tracs.length, 3, "TRACS should have 3 upcoming session")
    
    upcoming_gato = Topic.find( topics( :gato ) ).upcoming_sessions
    assert_equal( upcoming_gato.length, 3, "Gato should have 3 upcoming sessions")
  end

end
