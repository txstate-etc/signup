ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end


def login_as( login )
  @controller.instance_variable_set("@_current_user", nil)
  @request.session[ :user ] = login.id
end

# Runs assert_difference with a number of conditions and varying difference
# counts.
#
# Call as follows:
#
# assert_differences([['Model1.count', 2], ['Model2.count', 3]])
#
def assert_differences(expression_array, message = nil, &block)
  b = block.send(:binding)
  before = expression_array.map { |expr| eval(expr[0], b) }

  yield

  expression_array.each_with_index do |pair, i|
    e = pair[0]
    difference = pair[1]
    error = "#{e.inspect} didn't change by #{difference}"
    error = "#{message}\n#{error}" if message
    assert_equal(before[i] + difference, eval(e, b), error)
  end
end
