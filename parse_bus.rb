require_relative './config/environment'
@source = GTFS::Source.build('./data/google_transit_queens.zip')

stops = @source.stop_times
stations = @source.stops
route_start_hash = {}

#create stations
stations.each do |station|
	Station.create(:name => station.id, :lat => station.lat, :lon => station.lon)
end

def minuteparser(time)
	split_time = time.split(":")
	minutes = (split_time[0].to_i * 60) + split_time[1].to_i
	return minutes
end

stops.each do |stop|

	#setup data for migration
	trip_id = stop.trip_id
	id_array = trip_id.split(/-/)
	
	sub_array = id_array.last.split(/_/)
	start = sub_array.first[0..3].to_i
	carid = sub_array[1]

	if stop.trip_id.include?("Weekday")
		#setup route
		Route.create(:carid => carid, :starting => start, :color => "255,255,255", :serviceid => trip_id) if route_start_hash.has_key?(trip_id) == false
		route_start_hash[trip_id] = nil

		#setup stops
		car = Route.find_by(serviceid: trip_id)
		departure_time = minuteparser(stop.departure_time)
		arrival_time = minuteparser(stop.departure_time)
		Stop.create(:stopsequence => stop.stop_sequence, :departure => departure_time, :arrival => arrival_time, :route_id => car.id, :lat => Station.where(:name => stop.stop_id).first.lat, :lon => Station.where(:name => stop.stop_id).first.lon)
	end
end

# Route.where(:stop_count => nil).each do |route|
# 		stop_count = route.stops.count
# 		route.update_attributes(stop_count: stop_count)
# end

# jruby -J-Xmn512m -J-Xms2048m -J-Xmx2048m parse_bus.rb