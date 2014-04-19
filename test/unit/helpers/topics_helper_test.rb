require 'test_helper'

class TopicsHelperTest < ActionView::TestCase
  test "grouped_by_date" do
    sessions = grouped_by_date Topic.upcoming

    assert_equal 6, sessions.keys.length
    assert_equal 4, sessions[Date.new(2035, 6, 2)].length
    #CANCELLED: assert_equal 1, sessions[Date.new(2035, 8, 2)].length
    assert_equal 1, sessions[Date.new(2035, 9, 2)].length
    assert_equal 1, sessions[Date.new(2035, 6, 15)].length
    assert_equal 1, sessions[Date.new(2035, 7, 1)].length
    assert_equal 1, sessions[Date.new(2037, 7, 1)].length
    assert_equal 1, sessions[Date.new(2045, 5, 7)].length
    # 2nd OCCURRENCE: assert_equal 2, sessions[Date.new(2045, 5, 9)].length
  end
end
