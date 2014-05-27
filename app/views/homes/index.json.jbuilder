json.array!(@homes) do |home|
  json.extract! home, :id, :address, :city, :province, :postal_code, :beds, :baths, :data
  json.url home_url(home, format: :json)
end
