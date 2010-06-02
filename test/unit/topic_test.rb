require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  fixtures :topics
  
  def test_upcoming_sessions
    upcoming_tracs = Topic.find( topics( :tracs ) ).upcoming_sessions
    assert_equal( upcoming_tracs.length, 1, "TRACS should have 1 upcoming session")
    
    upcoming_gato = Topic.find( topics( :gato ) ).upcoming_sessions
    assert_equal( upcoming_gato.length, 2, "Gato should have 2 upcoming sessions")
  end

end
