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

  test "grouped_by_department" do
    sorted_departments = []

    groups = grouped_by_department(Topic.upcoming) do |department, topics|
      sorted_departments << department
    end

    assert_equal departments( :its ), sorted_departments[0]
    assert_equal departments( :tr ), sorted_departments[1]

    assert_equal 2, groups.keys.length
    assert_equal 2, groups[departments( :its )].length
    assert_equal 1, groups[departments( :tr )].length
  end

  test "in_month" do
    occurrences = in_month(Date.new(2035, 06))
    assert_equal 2, occurrences.keys.length
    assert_equal 4, occurrences[Date.new(2035, 6, 2)].length
    assert_equal 1, occurrences[Date.new(2035, 6, 15)].length

    occurrences = in_month(Date.new(2045, 05))
    assert_equal 2, occurrences.keys.length
    assert_equal 1, occurrences[Date.new(2045, 5, 7)].length
    assert_equal 2, occurrences[Date.new(2045, 5, 9)].length
  end
end
