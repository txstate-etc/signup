json.array!(@reservations) do |reservation|
  json.extract! reservation, :id, :user_id, :session_id, :cancelled, :attended, :special_accommodations
  json.url reservation_url(reservation, format: :json)
end
