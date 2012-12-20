require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  fixtures :departments, :topics
  # Replace this with your real tests.
  test "Initial relationships work" do
    assert_equal 3, departments( :its ).topics.size
  end
  
  test "Inactive topics not listed" do
    assert_equal 0, departments(:department_to_make_inactive).topics.size
    assert_equal departments(:department_to_make_inactive), topics(:inactive_topic).department
  end
  
  test "Blank Permissions are not added" do
    d = Department.new "name"=>"Test Perms", "permissions_attributes"=>{"0"=>{"name_and_login"=>""}}
    d.valid?
    assert_equal [], d.errors.full_messages
    assert d.save, "Failed to save new department"
    d.reload
    assert_equal [], d.permissions
  end

  test "Invalid Permissions are not added" do
    d = Department.new "name"=>"Test Perms", "permissions_attributes"=>{"0"=>{"name_and_login"=>"FAKEUSER"}}
    assert !d.save, "Department should not have saved"
    assert_equal 1, d.errors.full_messages.count
    assert_match /not found/, d.errors[:'permissions.user_id']
  end
  
  test "Deleting a department with topics makes it inactive" do
    d = departments(:department_to_make_inactive)
    d.deactivate!
    d.reload
    assert_equal true, d.inactive
  end

  test "Deleting a department with NO topics actually deletes it" do
    departments(:department_to_be_deleted).deactivate!
    assert_raise ActiveRecord::RecordNotFound do
      Department.find(departments(:department_to_be_deleted)) 
    end
  end
end
