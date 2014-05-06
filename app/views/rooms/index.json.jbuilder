json.array!(@rooms) do |room|
  json.extract! room, :id, :name, :organization_id
  json.url room_url(room, format: :json)
end
