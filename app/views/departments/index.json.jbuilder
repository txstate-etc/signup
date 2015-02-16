json.array!(@departments) do |department|
  json.extract! department, :id, :name, :inactive
  json.url department_url(department, format: :json)
end
