require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  fixtures :topics, :departments
  
  def test_upcoming_sessions
    upcoming_tracs = Topic.find( topics( :tracs ) ).upcoming_sessions
    assert_equal( upcoming_tracs.length, 4, "TRACS should have 4 upcoming session")
    
    upcoming_gato = Topic.find( topics( :gato ) ).upcoming_sessions
    assert_equal( upcoming_gato.length, 4, "Gato should have 4 upcoming sessions")

    upcoming_multi = Topic.find( topics( :multi_time_topic ) ).upcoming_sessions
    assert_equal( upcoming_multi.length, 1, "Multi Time Topic should have 1 upcoming session")
  end
  
  test "Verify that past sessions are computed correctly" do
    past_tracs = topics( :tracs ).past_sessions
    assert_equal( past_tracs.length, 1 )
    
    past_gato = topics( :gato ).past_sessions
    assert_equal( past_gato.length, 2 )

    past_multi = topics( :multi_time_topic ).past_sessions
    assert_equal( past_multi.length, 2 )
  end
  
  test "Verify CSV" do
    csv = topics( :tracs ).to_csv
    assert_equal 5, csv.split(/\n/).size, "CSV for TRACS should have 5 lines"
    
    csv = topics( :gato ).to_csv
    assert_equal 11, csv.split(/\n/).size, "CSV for Gato should have 11 lines"
  end
  
  test "Should find survey responses correctly" do
    assert_equal 2, topics( :gato ).survey_responses.size
    assert_equal 0, topics( :tracs ).survey_responses.size
  end

  test "Should compute average ratings correctly" do
    assert_equal 3.0, topics( :gato ).average_rating
    assert_equal 3.0, topics( :gato ).average_instructor_rating
  end
  
  test "Verify relationship to Departments" do
    assert_equal departments( :its ), topics( :gato ).department
  end

  test "Verify relationship to Documents" do
    topic = topics( :topic_with_attached_documents )
    assert_equal 2, topic.documents.size
    assert_equal documents( :attached_document_1 ), topic.documents[0]
    assert_equal documents( :attached_document_2 ), topic.documents[1]
  end

  test "Should delete new documents on update failure" do
    topic = topics( :topic_with_attached_documents )
    topic.minutes = nil
    assert_equal 2, topic.documents.size
    document = topic.documents.build
    document.item = File.new("#{Rails.root}/test/fixtures/topics.yml")
    assert document.new_record?
    assert_equal 3, topic.documents.size
    assert_equal false, topic.valid?
    assert_equal 2, topic.documents.size
  end
end
