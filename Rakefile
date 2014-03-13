
task :environment do
	require_relative './config/environment'
end

task :console => [:environment] do
	Pry.start
end

task :setup => :environment do
	@source = GTFS::Source.build('./data/google_transit.zip')
	Dir.glob("db/migrate/*").each do |f|
		require_relative f
		migration_name = f.gsub("db/migrate/", "").gsub(".rb", "").gsub(/\d+/, "").split("_").collect(&:capitalize).join
		begin
			Kernel.const_get(migration_name).migrate(:up)
		rescue; end
	end

end

task :seed => [:environment] do
	@source = GTFS::Source.build('./data/google_transit.zip')

	routes = @source.routes
	stops = @source.stop_times
	stations = @source.stops

	#create stations
	stations.each do |station|
		Station.create(:name => station.id, :lat => station.lat, :lon => station.lon)
	end

	#missing stations; GTFS error; Station is deprecated
	Station.create(:name => "R60", :lat => 40.752553, :lon => -73.944152)
	Station.create(:name => "R60N", :lat => 40.752553, :lon => -73.944152)
	Station.create(:name => "R60S", :lat => 40.752553, :lon => -73.944152)

	#empty hash to collect route information
	route_color_hash = {}
	route_start_hash = {}

	routes.each do |route|
		if route.color == nil || route.color == ""
			rgb = "255,255,255"
		elsif route.color != nil
			rgb = route.color.scan(/../).collect {|i| i.hex }.join(",")
		end

		route_color_hash[route.id] = rgb
		
	end

	def minuteparser(time)
		split_time = time.split(":")
		minutes = (split_time[0].to_i * 60) + split_time[1].to_i
		return minutes
	end
	
	stops.each do |stop|

		#setup data for migration
		trip_id = stop.trip_id
		id_array = trip_id.split(/_|\W{2}|(\d{2}R)|\d{7,}/)
		
		week = id_array[1]
		start = id_array[2][0..3].to_i
		carid = id_array[3]
		direction = id_array[4]

		if week == "WKD"
			#setup route
			Route.create(:carid => carid, :starting => start, :color => route_color_hash[carid], :serviceid => trip_id) if route_start_hash.has_key?(trip_id) == false
			route_start_hash[trip_id] = nil

			#setup stops
			car = Route.all.find_by(serviceid: trip_id)
			departure_time = minuteparser(stop.departure_time)
			arrival_time = minuteparser(stop.departure_time)
			Stop.create(:stopsequence => stop.stop_sequence, :departure => departure_time, :arrival => arrival_time, :route => car, :lat => Station.where(:name => stop.stop_id).first.lat, :lon => Station.where(:name => stop.stop_id).first.lon)
			# following comment checks for missing stations; R60 missing currently
			# puts stop.stop_id if Station.where(:name => stop.stop_id) == nil || Station.where(:name => stop.stop_id) == []
		end
	end
end

#sets all the missing endtime
task :end_time => [:environment] do
	Route.all.each do |route|
		end_time = route.stops.order(arrival: :desc).first.arrival
		route.update_attributes(ending: end_time)
	end
end

#fills empty color fields to white
task :fill_color => [:environment] do
	Route.all.each do |route|
		if route.color == nil
			route.update_attributes(color: "255,255,255")
		end
	end
end

task :stop_count => [:environment] do
	Route.all.each do |route|
		stop_count = route.stops.count
		route.update_attributes(stop_count: stop_count)
	end
end


















#seed for bus
# task :seed_bus => [:environment] do
# 	@source = GTFS::Source.build('./data/google_transit_manhattan.zip')

# 	routes = @source.routes
# 	stops = @source.stop_times
# 	stations = @source.stops

# 	#create stations
# 	stations.each do |station|
# 		Station.create(:name => station.id, :lat => station.lat, :lon => station.lon)
# 	end

# 	def minuteparser(time)
# 		split_time = time.split(":")
# 		minutes = (split_time[0].to_i * 60) + split_time[1].to_i
# 		return minutes
# 	end
	
# 	stops.each do |stop|

# 		#setup data for migration
# 		trip_id = stop.trip_id
# 		id_array = trip_id.split(/-/)
		
# 		week = id_array[1]
# 		sub_array = id_array.last.split(/_/)
# 		start = sub_array.first[0..3].to_i
# 		carid = sub_array[1]

# 		if week == "Weekday"
# 			#setup route
# 			Route.create(:carid => carid, :starting => start, :color => "255,255,255", :serviceid => trip_id) if route_start_hash.has_key?(trip_id) == false
# 			route_start_hash[trip_id] = nil

# 			#setup stops
# 			car = Route.find_by(serviceid: trip_id)
# 			departure_time = minuteparser(stop.departure_time)
# 			arrival_time = minuteparser(stop.departure_time)
# 			Stop.create(:stopsequence => stop.stop_sequence, :departure => departure_time, :arrival => arrival_time, :route => car, :lat => Station.where(:name => stop.stop_id).first.lat, :lon => Station.where(:name => stop.stop_id).first.lon)
# 		end
# 	end
# end
# Type `rake -T` on your command line to see the available rake tasks.