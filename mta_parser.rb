require 'gtfs'


source = GTFS::Source.build('./google_transit.zip')
stop = source.stops.first

puts stop.id
puts stop.name

puts stop.lat
puts stop.lon

a = source.stop_times.first
puts a.trip_id
puts a.departure_time
puts a.stop_id
