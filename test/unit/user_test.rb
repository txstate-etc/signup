require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users
  # Replace this with your real tests.
  test "Make sure name_and_login synthesized attribute works" do
    assert_equal users( :plainuser1 ).name_and_login, users( :plainuser1 ).name + " (" + users( :plainuser1 ).login + ")"
  end
end
