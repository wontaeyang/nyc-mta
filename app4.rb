require_relative './config/environment'

def setup
	#drawing setup
	#make sure to recalculate based on new dataset!!!
	size 1018, 800 #caculated from ratio of max/min values of gps coord
	smooth #anti-aliasing

	#set font
	text_font create_font("Helvetica Neue", 16)

	#variable setup
	$time = 0.0
	#radius setup
	$radius = 6.0
	#animation delay
	$delay = 3.0
	#timeline animation
	$timeline_loop = true

	#initialize timeline
	@timer = Timer.new

	#setup a hash trains with minutes they start operating
	@schedule = {}
	1440.times do |i|
		# array = Route.includes(:stops).where(:starting => i)
		array = Route.where(:starting => i)
		@schedule[i] = array if !array.empty?
	end

	#setup active cars
	$active_cars = []
end

def draw
	#refresh background
	background 17

	#draw title
	fill 255
	text("NYC ON RAILS", 70, 100)

	#draw sub-title
	fill 120
	text("03.13.2014", 70, 115)

	#update functions for classes
	if $timeline_loop == true
		@timer.update
		#initialize on demand
		init_vehicles
		#update active cars
		$active_cars.each {|car| car.update}
	end
end

#method for initializing vehicles from schedule
def init_vehicles
	id_array = @schedule[$time.to_i]
	if id_array != nil
		id_array.each do |car| 
			Vehicle.new(car.attributes, car.stops) if !car.stops.empty?
		end
	end
	@schedule[$time.to_i] = nil  #reset cars in minutes to nil to free memory
end


#end of processing methods
#---------------------------------------------------------------------------
#begin helper classes



class Timer
	include Processing::Proxy #includes all the processing methods
	def initialize
		@time_tween = 0.0
		@end_time = 1440.0
	end

	def update
		#time counter tween
		@time_tween += (100 - @time_tween)/$delay

		#update function to draw time text
		if @time_tween > 95
			$time += 1
			@time_tween = 0
			#stop animation and set time to 0 if it reaches end of time
			if $time >= @end_time
				$time = 0.0
				$timeline_loop = false
			end
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
			line((spacing - (@tick_increment / 2)), 0, (spacing - (@tick_increment / 2)), 14)
		end

		#line for actual minute
		stroke(255, 0, 0)
		stroke_weight(4)
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

	def initialize(attributes, init_stops)
		#save ID for later use
		@route_id = attributes["id"]

		#split color and assign it to each RBGA value
		color = attributes["color"].split(",")
		@r = color[0].to_i
		@g = color[1].to_i
		@b = color[2].to_i
		@a = 255.0

		#load stops
		@stops = init_stops

		#instance variables for current stop and next stop
		@current_stop = 0
		@last_stop = attributes["stop_count"] - 1

		#set location data
		@current_x = normalize_x(@stops[@current_stop].lon)
		@current_y = normalize_y(@stops[@current_stop].lat)
		@next_x = @current_x
		@next_y = @current_y

		#trigger time
		@trigger_time = @stops[@current_stop].departure

		#add to active cars
		$active_cars << self
	end

	def normalize_y(coord)
		map(coord, 40.632836, 40.903125, $app.height, 0)
	end

	def normalize_x(coord)
		map(coord, -74.020065, -73.78121, 0 + 50, $app.width - 50)
	end

	#method to update next target location
	def set_next_stop
		@current_stop += 1
		@next_x = normalize_x(@stops[@current_stop].lon)
		@next_y = normalize_y(@stops[@current_stop].lat)
		@trigger_time = @stops[@current_stop].departure
	end

	def update
		#set color for the train
		fill @r, @g, @b, @a
		no_stroke

		#easing animation to next location
		@current_x += (@next_x - @current_x)/$delay
		@current_y += (@next_y - @current_y)/$delay
		
		#draw circle for train
		ellipse(@current_x.to_i, @current_y.to_i, $radius, $radius)

		#check trigger time and update next location
		if @trigger_time == $time && @current_stop < @last_stop
			set_next_stop
		elsif @trigger_time == $time && @current_stop == @last_stop
			@a = 0
			$active_cars.delete_if {|car| car == self }
		end
	end

end
