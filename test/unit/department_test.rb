require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  fixtures :departments, :topics
  # Replace this with your real tests.
  test "Initial relationships work" do
    assert_equal departments( :its ).topics.size, 2
  end
end
