require_relative './config/environment'

def setup
	#drawing setup
	#make sure to recalculate based on new dataset!!!
	size 1018, 800
	smooth #anti-aliasing

	#set font
	text_font create_font("Helvetica Neue", 16)

	#variable setup
	$time = 0.0
	#radius setup
	$radius = 7.0

	#initialize timeline
	@timer = Timer.new

	# @subways = Route.all.collect {|sub| Vehicle.new(sub) }
	# @subways = Route.all.collect {|sub| Vehicle.new(sub) }

	#setup schedule hash
	@schedule = {}

	1440.times do |i|
		array = Route.where(:starting => i).collect { |route| route.id }
		@schedule[i] = array if !array.empty?
	end

	#setup active cars
	$active_cars = []
end

def draw
	#refresh background
	background 30

	#draw title
	fill 255
	text("NYC ON RAILS", 70, 100)

	#draw sub-title
	fill 120
	text("03.10.2014", 70, 115)

	#update functions for classes
	@timer.update
	init_vehicles

	$active_cars.each {|car| car.update}

	#this saves every frame as png
	# save_frame("./output2/seq-1#####.png")
end


def init_vehicles
	id_array = @schedule[$time.to_i]
	if id_array != nil
		id_array.each { |car| Vehicle.new(Route.find(car).attributes)}
	end
end


#end of processing methods
#---------------------------------------------------------------------------
#begin helper classes



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
		@tick_increment = ($app.width.to_f) / 24.0
		@tick_spacing = []
		(1..24).each {|i| @tick_spacing.push(i * @tick_increment)}
		@tick_spacing.each do |spacing|
			stroke(135)
			stroke_weight(2)
			stroke_cap(SQUARE)
			line(spacing, 0, spacing, 20)
			stroke(85)
			stroke_weight(2)
			stroke_cap(SQUARE)
			line((spacing - (@tick_increment / 2)), 0, (spacing - (@tick_increment / 2)), 14)
		end

		#line for actual minute
		stroke(255, 0, 0)
		stroke_weight(4)
		stroke_cap(SQUARE)
		@loc_timeline = map($time, 0, 1440, 0, $app.width)
		line(@loc_timeline, 0, @loc_timeline, 28)

		#text draw and update every frame
		@hour = ($time / 60.0).floor
		@minute = $time - (@hour * 60.0)
		@text_translate = map($time, 0.0, 1440.0, 0.0, 42.0 )
		fill 255
		text( @hour.to_i.to_s + "." + @minute.to_i.to_s, @loc_timeline - @text_translate, 43) 
	end
end

class Vehicle
	include Processing::Proxy
	attr_accessor :route_id

	def initialize(attributes)
		@route_id = attributes["id"]
		#color setting setup
		color = attributes["color"].split(",")
		@r = color[0].to_i
		@g = color[1].to_i
		@b = color[2].to_i
		@a = 0

		#load stops
		@stops = Route.find(@route_id).stops.first

		#instance variables for current stop and next stop
		@current_stop = 0
		@last_stop = attributes["stop_count"] - 1

		#set location data
		@current_x = normalize_x(@stops.lon)
		@current_y = normalize_y(@stops.lat)
		@next_x = @current_x
		@next_y = @current_y

		#trigger time
		@trigger_time = @stops.departure
		@delay = 4.0

		#add to active cars
		$active_cars << self
	end

	def normalize_y(coord)
		map(coord, 40.632836, 40.903125, $app.height, 0)
	end

	def normalize_x(coord)
		map(coord, -74.014065, -73.828121, 0 + 50, $app.width - 50)
	end

	#method to update next target location
	def set_stop
		@stops = Route.find(@route_id).stops[@current_stop]

		@next_x = normalize_x(@stops.lon)
		@next_y = normalize_y(@stops.lat)
		@trigger_time = @stops.departure
	end

	def update
		#set color for the train
		fill @r, @g, @b, @a
		no_stroke

		#easing animation to next location
		@current_x += (@next_x - @current_x)/@delay
		@current_y += (@next_y - @current_y)/@delay
		
		#draw circle for train
		ellipse(@current_x.to_i, @current_y.to_i, $radius, $radius)

		#check trigger time and update next location
		if @trigger_time == $time && @current_stop < @last_stop
			@current_stop += 1
			set_stop
			@a = 256 if @a != 256
		elsif @trigger_time == $time && @current_stop == @last_stop
			@a = 0
			$active_cars.delete_if {|car| car == self }
		end
	end

end
