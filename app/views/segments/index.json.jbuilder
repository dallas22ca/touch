json.array!(@segments) do |segment|
  json.extract! segment, :id, :name, :filters, :organization_id
  json.url segment_url(segment, format: :json)
end
