require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  fixtures :sessions
  # Replace this with your real tests.
  test "Should determine whether space is available correctly" do
    session = Session.find( sessions( :tracs_tiny ) )
    assert session.space_is_available?

    session = Session.find( sessions( :tracs_tiny_full ) )
    assert !session.space_is_available?

    session = Session.find( sessions( :gato_huge ) )
    assert session.space_is_available?    
  end
end
