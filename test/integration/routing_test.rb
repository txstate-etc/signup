require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  test "redirect routes work" do
    # get '/topics/upcoming', to: redirect('/'), as: :upcoming
    get upcoming_path
    assert_response :redirect
    assert_redirected_to root_path

    # get '/sessions/attendance/:id', to: redirect('/sessions/%{id}/reservations')
    session = sessions(:gato)
    get "/sessions/attendance/#{session.to_param}"
    assert_response :redirect
    assert_redirected_to sessions_reservations_path(session)

  end
end
