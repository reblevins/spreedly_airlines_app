json.extract! flight, :id, :flight_number, :origin_id, :destination_id, :start_time, :duration, :price, :created_at, :updated_at
json.url flight_url(flight, format: :json)
