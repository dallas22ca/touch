json.array!(@documents) do |document|
  json.extract! document, :id, :channel_id
  json.url document_url(document, format: :json)
end
