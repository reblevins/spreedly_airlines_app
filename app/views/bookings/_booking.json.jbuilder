json.extract! booking, :id, :flight_id, :first_name, :last_name, :confirmation_code, :created_at, :updated_at
json.url booking_url(booking, format: :json)
