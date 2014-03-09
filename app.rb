require_relative './config/environment'
require 'ruby-processing'


def setup
	#drawing setup
	size 550, 800
	smooth
	text_size(18);
	text_font create_font("Helvetica Neue", 14)

	#variable setup
	$time = 0.0

	#initialize
	@timer = Timer.new
end

def draw
	#refresh background
	background 0


	
	@timer.update

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
		text( @hour.to_i.to_s + "." + @minute.to_i.to_s, @loc_timeline - @text_translate, 35); 
	end
end

class Vehicle
	include Processing::Proxy

	def initialize
	end

	def update
	end

end
