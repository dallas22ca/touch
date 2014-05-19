json.array!(@comments) do |comment|
  json.extract! comment, :id, :folder_id, :creator_id, :body
  json.url comment_url(comment, format: :json)
end
