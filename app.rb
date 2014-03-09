require_relative './config/environment'
require 'ruby-processing'
include_package "processing.video"

def setup
	#drawing setup
	size 550, 800
	smooth
	text_size(18);
	text_font create_font("Helvetica Neue", 14)

	#variable setup
	$time = 0.0
	#radius setup
	$radius = 7.0

	#initialize
	@timer = Timer.new
	# @subway = Vehicle.new(Route.find(1171))
	@subways = Route.where(carid: "1").collect {|sub| Vehicle.new(sub) }
	
end

def draw
	#refresh background
	background 0
	@timer.update
	@subways.each {|sub| sub.update}
	# @subway.update
	save_frame("./output/seq-######.png")

end



#---------------------------------------------------------------------------



class Timer
	include Processing::Proxy
	def initialize
		@time_tween = 0.0
		@end_time = 1440.0
		@delay = 3.0
	end

	def update
		#time counter tween
		@time_tween += (100 - @time_tween)/@delay

		#update function to draw time text
		if @time_tween > 90
			$time += 1
			@time_tween = 0
			$time = 0.0 if $time >= @end_time
			stroke(255, 0, 0)
		end

		#timeline
		@tick_increment = $app.width/24
		@tick_spacing = []
		(1..24).each {|i| @tick_spacing.push(i * @tick_increment)}
		@tick_spacing.each do |spacing|
			stroke(100)
			stroke_weight(1)
			stroke_cap(SQUARE)
			line(spacing, 0, spacing, 18)
			stroke(50)
			stroke_weight(1)
			stroke_cap(SQUARE)
			line((spacing - (@tick_increment / 2)), 0, (spacing - (@tick_increment / 2)), 10)
		end

		#line for actual minute
		stroke(255, 0, 0)
		stroke_weight(3)
		stroke_cap(SQUARE)
		@loc_timeline = map($time, 0, 1440, 0, $app.width)
		line(@loc_timeline, 0, @loc_timeline, 22)

		#text draw and update every frame
		@hour = ($time / 60.0).floor
		@minute = $time - (@hour * 60.0)
		@text_translate = map($time, 0.0, 1440.0, 0.0, 33.0 )
		fill 255
		text( @hour.to_i.to_s + "." + @minute.to_i.to_s, @loc_timeline - @text_translate, 35); 
	end
end

class Vehicle
	include Processing::Proxy
	attr_accessor :route, :stops, :lat, :lon, :start_time, :trigger_time

	def initialize(route)
		@route = route

		#color setting setup
		@color = route.color.split(",")
		@r = @color[0].to_i
		@g = @color[1].to_i
		@b = @color[2].to_i
		@a = 0

		@stops = route.stops
		@current_stop = 0

		@current_x = normalize_x(@stops[@current_stop].lon)
		@current_y = normalize_y(@stops[@current_stop].lat)
		@next_x = @current_x
		@next_y = @current_y

		@trigger_time = @stops[@current_stop].departure
		@delay = 5.0
		
	end

	def normalize_y(coord)
		map(coord, 40.632836, 40.903125, $app.height, 0)
	end

	def normalize_x(coord)
		map(coord, -74.014065, -73.828121, 0, $app.width)
	end

	def update
		fill @r, @g, @b, @a
		no_stroke
		@current_x += (@next_x - @current_x)/@delay
		@current_y += (@next_y - @current_y)/@delay
		
		ellipse(@current_x.to_i, @current_y.to_i, $radius, $radius)



		if @trigger_time == $time && @current_stop < @stops.size - 1
			@next_x = normalize_x(@stops[@current_stop + 1].lon)
			@next_y = normalize_y(@stops[@current_stop + 1].lat)
			@trigger_time = @stops[@current_stop + 1].departure
			@a = 256
			@current_stop += 1
		elsif @current_stop == @stops.size - 1
			@a = 0
	
		end
	end

end
