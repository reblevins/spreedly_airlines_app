# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
airports = Airport.create([{ code: 'SFO', city: 'San Francisco' }, { code: 'NYC', city: 'New York City' }])

Flight.create([
  {
    flight_number: 'SA001',
    origin: airports.first,
    destination: airports.last,
    start_time: DateTime.parse('2021-11-01 09:00:00'),
    duration: 4,
    price: 300
  },
  {
    flight_number: 'SA002',
    origin: airports.last,
    destination: airports.first,
    start_time: DateTime.parse('2021-11-01 10:00:00'),
    duration: 4,
    price: 400
  },
  {
    flight_number: 'SA003',
    origin: airports.first,
    destination: airports.last,
    start_time: DateTime.parse('2021-11-02 09:00:00'),
    duration: 4,
    price: 500
  },
  {
    flight_number: 'SA004',
    origin: airports.last,
    destination: airports.first,
    start_time: DateTime.parse('2021-11-02 10:00:00'),
    duration: 4,
    price: 600
  },
  {
    flight_number: 'SA005',
    origin: airports.first,
    destination: airports.last,
    start_time: DateTime.parse('2021-11-03 09:00:00'),
    duration: 4,
    price: 700
  },
  {
    flight_number: 'SA006',
    origin: airports.last,
    destination: airports.first,
    start_time: DateTime.parse('2021-11-03 10:00:00'),
    duration: 4,
    price: 800
  }
])
