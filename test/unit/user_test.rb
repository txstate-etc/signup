require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users
  # Replace this with your real tests.
  test "Make sure users without first names work" do
    assert_equal users( :instructor1 ).name, "Instructor1"
  end

  test "Make sure name_and_login synthesized attribute works" do
    assert_equal users( :plainuser1 ).name_and_login, "Plain User1 (pu12345)"
  end
end
