require 'test_helper'

class OccurrenceTest < ActiveSupport::TestCase
  test "Occurences should be sorted by time by default" do
    test_session = Session.find( sessions( :gato ).id )
    assert_difference 'test_session.occurrences.count', +2 do
      test_session.occurrences.create(:time => DateTime.parse('2025-04-29T12:00:00'))
      test_session.occurrences.create(:time => DateTime.parse('2025-04-27T15:00:00'))
    end    
    assert_equal 3, test_session.occurrences.count    
    assert_operator test_session.occurrences[0].time, :<=, test_session.occurrences[1].time
    assert_operator test_session.occurrences[1].time, :<=, test_session.occurrences[2].time 
  end
  
  test "Occurrence without time is not valid" do
    test_occurrence = Occurrence.new(:session => sessions( :gato ))
    assert !test_occurrence.save
  end

  test "Occurrence with time is valid" do
    test_occurrence = Occurrence.new(:time => DateTime.parse('2025-04-29T12:00:00'), :session => sessions( :gato ))    
    assert test_occurrence.save
  end
end
