# First we pull in the standard API hooks.
require 'sketchup.rb'

#Show the Ruby Console at Startup so we can
#see any porgramming errors we make.
SKETCHUP_CONSOLE.show

# Add a menu item to launch the plugin.
UI.menu("Plugins").add_item("Draw Discs") {
	UI.messagebox("I'm about to draw discs")
	
	# Define a few things
	POINTS_NUM = 10
	CUBE_SIZE = 10.0
		
	#run some methods
	draw_discs
	}


def draw_discs
	
	#Create some variables
	radius = 0.5
	thickness = 0.1
	
	# Create an array of vectors to be used as random points for disc positioning
	arr = Array.new(POINTS_NUM) {Array.new(3)}
	
	# Initiate Pseudo Random Number Generator
	prng = Random.new
		
	# Populate the Array	
	for step in 0..(POINTS_NUM)
	
		x = prng.rand(CUBE_SIZE)
		y = prng.rand(CUBE_SIZE)
		z = prng.rand(CUBE_SIZE)	
		arr[step] = [x,y,z]
	
	end
	
	# Get "handles" to our model and the Entities collection it contains
	model = Sketchup.active_model
	entities = model.entities
	
	# Loop across the same code several times
	for step in 1..(POINTS_NUM)
		
		#Calculate a random direction
		vector = Geom::Vector3d.new 0,0,1
			
		
		#Call methods on the entitites collection to draw stuff
		new_circleedges = entities.add_circle arr[step], vector, radius 
		new_circle = entities.add_face(new_circleedges)
		new_circle.pushpull thickness
	end
		
end

