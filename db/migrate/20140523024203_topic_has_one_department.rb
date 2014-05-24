class TopicHasOneDepartment < ActiveRecord::Migration
  def change
    add_reference :topics, :department, index: true
  end
end
