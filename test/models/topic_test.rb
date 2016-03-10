require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  fixtures :topics, :departments
  
  def setup
    Reservation.counter_culture_fix_counts
  end

  test "Topic.Upcoming only shows topics with upcoming sessions" do
    upcoming = Topic.upcoming
    assert_equal 3, upcoming.length
    assert_equal topics(:tracs), upcoming.first
    assert_equal topics(:gato), upcoming.second
    assert_equal topics(:multi_time_topic), upcoming.third
  end

  test "Verify that active sessions are computed correctly" do
    active_tracs = topics( :tracs ).sessions
    assert_equal 5, active_tracs.length 
    
    active_gato = topics( :gato ).sessions
    assert_equal 6, active_gato.length

    active_multi = topics( :multi_time_topic ).sessions
    assert_equal 3, active_multi.length 
  end

  test "Verify that upcoming sessions are computed correctly" do
    upcoming_tracs = Topic.find( topics( :tracs ).id ).upcoming_sessions
    assert_equal 4, upcoming_tracs.length, "TRACS should have 4 upcoming session"
    
    upcoming_gato = Topic.find( topics( :gato ).id ).upcoming_sessions
    assert_equal 4, upcoming_gato.length, "Gato should have 4 upcoming sessions"

    upcoming_multi = Topic.find( topics( :multi_time_topic ).id ).upcoming_sessions
    assert_equal 1, upcoming_multi.length, "Multi Time Topic should have 1 upcoming session"
  end
  
  test "Verify that past sessions are computed correctly" do
    past_tracs = topics( :tracs ).past_sessions
    assert_equal 1, past_tracs.length 
    
    past_gato = topics( :gato ).past_sessions
    assert_equal 2, past_gato.length

    past_multi = topics( :multi_time_topic ).past_sessions
    assert_equal 2, past_multi.length 
  end
  
  test "Verify CSV" do
    csv = topics( :tracs ).to_csv
    assert_equal 5, csv.split(/\n/).size, "CSV for TRACS should have 5 lines"
    
    csv = topics( :gato ).to_csv
    assert_equal 13, csv.split(/\n/).size, "CSV for Gato should have 11 lines"
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
    document.item = File.new(__FILE__)
    assert document.new_record?
    assert_equal 3, topic.documents.size
    assert_equal false, topic.valid?
    assert_equal 2, topic.documents.size
  end

  test "Topic with no name is not valid" do
    topic = Topic.new
    #topic.name = "some name"
    topic.description = "some description"
    topic.department = departments(:its)
    topic.minutes = 60

    assert !topic.valid?
  end

  test "Topic with no description is not valid" do
    topic = Topic.new
    topic.name = "some name"
    #topic.description = "some description"
    topic.department = departments(:its)
    topic.minutes = 60

    assert !topic.valid?
  end

  test "Topic with no department is not valid" do
    topic = Topic.new
    topic.name = "some name"
    topic.description = "some description"
    #topic.department = departments(:its)
    topic.minutes = 60

    assert !topic.valid?
  end

  test "Topic with no minutes is not valid" do
    topic = Topic.new
    topic.name = "some name"
    topic.description = "some description"
    topic.department = departments(:its)
    #topic.minutes = 60

    assert !topic.valid?
  end

  test "Minutes must be integer" do
    topic = Topic.new
    topic.name = "some name"
    topic.description = "some description"
    topic.department = departments(:its)
    topic.minutes = "foo"
    assert !topic.save 

    topic.minutes = 3.14
    assert !topic.save 

    topic.minutes = 99
    assert topic.save 

    topic = topics( :gato )
    assert !topic.update( { :minutes => "1.21"})

    topic = topics( :gato )
    assert !topic.update( { :minutes => ""})
  end

  test "Must have survey_url for external surveys" do
    topic = Topic.new
    topic.name = "some name"
    topic.description = "some description"
    topic.department = departments(:its)
    topic.minutes = 60
    topic.survey_type = Topic::SURVEY_EXTERNAL
    assert !topic.valid?
 
    topic.survey_url = "http://example.com/survey"
    assert topic.valid?
  end

  test 'Tag parsing works' do
    topic = topics( :gato )
    assert_equal 2, topic.tags.size
    assert_equal "gato", topic.sorted_tags.first.name
    assert_equal "its", topic.sorted_tags.last.name
    assert topic.update( { :tag_list => "foo, Two Words; $pEc|al çh4rs*  , "})
    topic.reload
    assert_equal 3, topic.tags.size
    assert_equal "foo", topic.sorted_tags.first.name
    assert_equal "p-ec-al-ch4rs", topic.sorted_tags.second.name
    assert_equal "two-words", topic.sorted_tags.last.name
  end

  test 'Should delete topic with no sessions' do
    topics( :topic_to_delete ).deactivate!
    assert_not Topic.exists?(topics( :topic_to_delete ).id)
  end

  test 'Should mark topic with past sessions as inactive' do
    topics( :topic_to_make_inactive ).deactivate!
    assert Topic.exists?(topics( :topic_to_make_inactive ).id)
    assert topics( :topic_to_make_inactive ).inactive
  end

  test 'Should NOT delete topic with upcoming sessions' do
    exception = assert_raises ActiveRecord::RecordInvalid do
      topics( :tracs ).deactivate!
    end
    assert_match /cannot delete a topic with upcoming sessions/, exception.message
    assert Topic.exists?(topics( :tracs ).id)
    topics( :tracs ).reload
    assert_not topics( :tracs ).inactive
  end
end
