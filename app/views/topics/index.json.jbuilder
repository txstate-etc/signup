json.array!(@topics) do |topic|
  json.extract! topic, :id, :name, :description, :url, :minutes, :inactive, :certificate, :survey_type, :survey_url
  json.url topic_url(topic, format: :json)
end
