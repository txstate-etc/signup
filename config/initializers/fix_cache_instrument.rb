# Cashier uses Rails instrumentation notifications to hook into cache writes
# for saving tags. Rails disables instrumentation in caching by default,
# and the enabled state is stored in a thread-local variable.
# Passenger forks a new process to handle requests, and this process
# does not carry over thread-local variables, so enabling instrumentation
# in an initializer does not work.
#
# This change monkey-patches the Rails code to just always enable instrumentation.
#
# See the original code here:
# https://github.com/rails/rails/blob/dd493d3b6f25147227db4c5d119d6b48c31f42e6/activesupport/lib/active_support/cache.rb#L183
ActiveSupport::Cache::Store.instance_eval do
  def self.instrument=(boolean)
    true
  end

  def self.instrument
    true
  end
end
