require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  fixtures :tags, :users
  
  # test "Index works" do
  #   get :index
  #   assert_response :success
  #   assert_equal 'All Tags', assigns(:page_title)
  #   #FIXME: make a better test once index does something useful
  # end

  test "Should be able to look up tags by ID" do
    tag = tags(:gato)
    get :show, :id => tag
    assert_response :success
    assert_equal tag, assigns(:tag)
    assert_equal "Topics Tagged With 'gato'", assigns(:page_title)
  end

  test "Should be able to look up tags by name" do
    get :show, :id => 'gato'
    assert_response :success
    assert_equal tags(:gato), assigns(:tag)
    assert_equal "Topics Tagged With 'gato'", assigns(:page_title)
  end

  test "Only admins should be able to download attendance history" do
    login_as( users( :plainuser1 ) )
    assert_raises ActionController::UnknownFormat, 'Should NOT be able to download attendance history' do
      get :show, :id => tags(:gato), :format => 'csv'
    end
    assert_equal 0, @response.body.length

    login_as( users( :instructor1 ) )
    assert_raises ActionController::UnknownFormat, 'Should NOT be able to download attendance history' do
      get :show, :id => tags(:gato), :format => 'csv'
    end
    assert_equal 0, @response.body.length

    login_as( users( :editor1 ) )
    assert_raises ActionController::UnknownFormat, 'Should NOT be able to download attendance history' do
      get :show, :id => tags(:gato), :format => 'csv'
    end
    assert_equal 0, @response.body.length

    login_as( users( :admin1 ) )
    get :show, :id => tags(:gato), :format => 'csv'
    assert_response :success
    assert_match %r{text/csv}, @response.content_type

  end
end
