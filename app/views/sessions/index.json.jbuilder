json.array!(@sessions) do |session|
  json.extract! session, :id, :topic_id, :cancelled, :location, :location_url, :site_id, :seats, :reg_start, :reg_end, :survey_sent
  json.url session_url(session, format: :json)
end
