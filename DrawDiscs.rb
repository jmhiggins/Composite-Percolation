# First we pull in the standard API hooks.
require 'sketchup.rb'

#Show the Ruby Console at Startup so we can
#see any porgramming errors we make.
SKETCHUP_CONSOLE.show

# Add a menu item to launch the plugin.
UI.menu("Plugins").add_item("Draw Discs") {
	UI.messagebox("I'm about to draw discs")
			
	#run some methods
	start_arr = Array.new
	start_arr = initial_props()
	draw_discs(start_arr)
	}

def initial_props

	# Method produces an input box requesting info on how to build the model

	prompts = ["How big is the RVE?", "How Many Discs to Create?", "Disc Diameter?", "Disc Thickness?"]
	defaults = [10.mm, 10, 1.0.mm, 0.1.mm]
	input = UI.inputbox(prompts, defaults, "Lets Build a Model!!!")

	return input
	
end
	
def draw_discs(prop_arr)
	
	#Create some variables
	cube_size = prop_arr[0]
	points_num = prop_arr[1] 
	radius = prop_arr[2]/2
	thickness = prop_arr[3]
	
	# Create an array of vectors to be used as random points for disc positioning
	arr = Array.new(points_num) {Array.new(3)}
	
	# Initiate Pseudo Random Number Generator
	prng = Random.new
		
	# Populate the Array	
	for step in 0..(points_num)
	
		x = prng.rand(cube_size)
		y = prng.rand(cube_size)
		z = prng.rand(cube_size)	
		arr[step] = [x,y,z]
	
	end
	
	# Get "handles" to our model and the Entities collection it contains
	model = Sketchup.active_model
	entities = model.entities
	
	# Loop across the same code several times
	for step in 1..(points_num)
		
		#Calculate a random direction
		vector = Geom::Vector3d.new 0,0,1
			
		
		#Call methods on the entitites collection to draw stuff
		new_circleedges = entities.add_circle arr[step], vector, radius 
		new_circle = entities.add_face(new_circleedges)
		new_circle.pushpull thickness
	end
		
end

