json.array!(@sequences) do |sequence|
  json.extract! sequence, :id, :strategy, :creator_id, :interval, :date, :organization_id
  json.url sequence_url(sequence, format: :json)
end
