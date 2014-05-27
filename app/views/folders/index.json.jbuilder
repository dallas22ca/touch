json.array!(@folders) do |folder|
  json.extract! folder, :id, :name, :archived
  json.url folder_url(folder, format: :json)
end
