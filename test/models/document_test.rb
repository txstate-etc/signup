require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  test "Friendly Name is Properly Titleized" do
    assert_equal documents( :attached_document_1 ).friendly_name, "Attached Document 1"
  end
end
