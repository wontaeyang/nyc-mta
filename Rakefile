
task :environment do
	require_relative './config/environment'
	@source = GTFS::Source.build('./google_transit.zip')
end

task :console => [:environment] do
	Pry.start
end

task :setup => :environment do
  Dir.glob("db/migrate/*").each do |f|
    require_relative f
    migration_name = f.gsub("db/migrate/", "").gsub(".rb", "").gsub(/\d+/, "").split("_").collect(&:capitalize).join
    begin
      Kernel.const_get(migration_name).migrate(:up)
    rescue; end
  end
end

task :seed => [:environment] do
	routes = @source.routes
	stops = @source.stop_times
	stations = @source.stops

	#create stations
	stations.each do |station|
		Station.create(:name => station.id, :lat => station.lat, :lon => station.lon)
	end

	#empty hash to collect route information
	route_color_hash = {}
	route_start_hash = {}

	routes.each do |route|
		if route.color != nil
			rgb = route.color.scan(/../).collect {|i| i.hex }.join(",")
		else
			rgb = "255,255,255"
		end

		route_color_hash[route.id] = rgb
		# Route.create(:carid => route.id, :color => rgb, :longname => route.long_name)
	end

	def minuteparser(time)
		split_time = time.split(":")
		minutes = (split_time[0].to_i * 60) + split_time[1].to_i
		return minutes
	end
	
	stops.each do |stop|

		#setup data for migration
		array = stop.trip_id.split(/_|\W{2}|(\d{2}R)/)
		serviceid = array[0]
		
		start = array[1][0..3].to_i
		carid = array[2]
		direction = array[3]

		if serviceid == "A20130803WKD"
			#setup route
			Route.create(:carid => carid, :starting => start, :color => route_color_hash[carid], :serviceid => serviceid) if route_start_hash.has_key?(start) == false
			route_start_hash[start] = nil

			#setup stops
			car = Route.all.find_by(starting: start)
			departure_time = minuteparser(stop.departure_time)
			arrival_time = minuteparser(stop.departure_time)
			Stop.create(:stopsequence => stop.stop_sequence, :departure => departure_time, :arrival => arrival_time, :route => car, :lat => Station.where(:name => stop.stop_id).first.lat, :lon => Station.where(:name => stop.stop_id).first.lon)
		end

	end

	Route.all.each do |route|
		end_time = route.stops.order(arrival: :desc).first.arrival
		route.update_attributes(ending: end_time)
	end

end

# Type `rake -T` on your command line to see the available rake tasks.