json.array!(@messages) do |message|
  json.extract! message, :id, :creator_id, :subject, :body, :member_ids, :organization_id
  json.url message_url(message, format: :json)
end
