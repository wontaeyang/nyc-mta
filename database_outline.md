Vehicles (HAS MANY SCHEDULE)
ID		NAME		COLOR

1		a 			blue
2		c 			blue
3		b 			orange
4		d 			orange


Schedule (BELONGS TO VEHICLE)
ID		VEHICLE_ID		STOP_NAME	TIME	LATTITUDE	LONGITUDE
1		2				FULTON		345		28.9843 	-94.9872


lat max = 40.903125
lat min = 40.512764

diff = 0.390361

lon max = -73.755405
lon min = -74.251961

diff = 0.496556


0.390361 / 0.496556 = 800 / x

x (0.390361 / 0.496556) = 800
x= 800 / (0.390361 / 0.496556)
x = 1017.6344460640279



- create schedule queue
- create list of active routes and pop if not active

schedule = {}

1440.times do |i|
array = Route.where(:starting => i).collect { |route| route.id }
schedule[i] = array if !array.empty?
end
