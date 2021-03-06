 #------------------------------------------------------------
# This is a plugin used to create models for calculations on
# percolative composites.  v1.3 2015/05/16, Jeremy Higgins 
# Eventually I will use this model to run some calculations
#------------------------------------------------------------

# First we pull in the standard API hooks.
require 'sketchup.rb'

#Show the Ruby Console at Startup so we can
#see any porgramming errors we make.
SKETCHUP_CONSOLE.show

# Add a menu item to launch the plugin.
UI.menu("Plugins").add_item("Draw Discs") {
	UI.messagebox("I'm about to draw discs")
		
	#Run the Methods

	# SETUP SEQUENCE
	
	# Handle for the model
	model = Sketchup.active_model
	entities = model.entities
	
	# Number of Models to setup sequentially
	prompts = ["Number of Runs = "]
	defaults = [1]
	numpass = UI.inputbox(prompts, defaults, "How Many Runs?")
		
	#Initialize the matrix of starting conditions
	start_arr = Array.new
	runseq_arr = Array.new {start_arr}
	
	#Fill out the starting condition matrix
	for step in 1..(numpass[0]) 
	
		start_arr = initial_props()
		runseq_arr[step-1] = start_arr
		prompts = ["Filename = "]
		defaults = ["Enter Name"]
		inputname = UI.inputbox(prompts, defaults, "Please Name this File")
		start_arr[5] = inputname
		save_file(inputname)
	
	end
	
	# MAIN SEQUENCE
	
	#Repeat Main sequence for each defined set of starting conditions in the starting conditions matrix
	for step in 1..(numpass[0])
		pass_arr = runseq_arr[step-1]
		draw_discs(pass_arr)
		draw_box(pass_arr)
		save_file(pass_arr[5])
		unless step = numpass[0]
			status = entities.clear!  #Clear the view by clearing entities collection
		end
	end
	}

def initial_props
#*******************************
#
# Method produces an input box requesting info on how to build the model
#
#*******************************


	prompts = ["How big is the RVE?", "How Many Discs to Create?", "Disc Diameter?", "Disc Thickness?","Random Disc Orientation"]
	defaults = [10.mm, 10, 1.0.mm, 0.1.mm, "no"]
	list = ["", "", "", "", "yes|no"]
	input = UI.inputbox(prompts, defaults, list, "Lets Build a Model!!!")

	return input
	
end
	
def draw_discs(prop_arr)
#*******************************
#
#Program which draws the discs
#
#*******************************

	#Create some variables based on the inputted array
	cube_size = prop_arr[0]
	points_num = prop_arr[1] - 1
	radius = prop_arr[2]/2
	thickness = prop_arr[3]
	randoyn = prop_arr[4]
	
	# Create an array of vectors to be used as random points for disc positioning and disc normal unit vector
	posarr = Array.new(points_num) {Array.new(3)}
	dirarr = Array.new(points_num) {Array.new(3)}
	
	# Initiate Pseudo Random Number Generator
	prng = Random.new
	
	# Populate one or both arrays as necessary
	for step in 0..(points_num)
		x = prng.rand(cube_size)
		y = prng.rand(cube_size)
		z = prng.rand(cube_size)	
		posarr[step] = [x,y,z]
		dirarr[step] = [0,0,1]
	end
	
	if randoyn == "yes"
		for step in 0..(points_num)
			theta = prng.rand(2 * Math::PI)
			phi = prng.rand(Math::PI)
			dirx = Math.sin(theta) * Math.cos(phi)
			diry = Math.sin(theta) * Math.sin(phi)
			dirz = Math.cos(theta)
			dirarr[step] = [dirx, diry, dirz]
		end
	end
	
	# Get "handles" to our model and the Entities collection it contains
	model = Sketchup.active_model
	entities = model.entities
	
	# Loop across the same code several times
	for step in 0..(points_num)
		
		#Calculate a random direction
		vector = Geom::Vector3d.new dirarr[step]
			
		#Call methods on the entitites collection to draw stuff
		new_circleedges = entities.add_circle posarr[step], vector, radius 
		new_circle = entities.add_face(new_circleedges)
		new_circle.pushpull thickness
	end
	
end

def draw_box(prop_arr)
#*******************************
#
# Adds RVE Limits as lines...i.e. adds a box around the unit cell
#
#*******************************

edge = prop_arr[0]
pt = Array.new
pt[0] = [0, 0, 0]
pt[1] = [edge, 0, 0]
pt[2] = [edge, edge, 0]
pt[3] = [0, edge, 0]
pt[4] = [0, 0, edge]
pt[5] = [edge, 0, edge]
pt[6] = [edge, edge, edge]
pt[7] = [0, edge, edge]

entities = Sketchup.active_model.entities

limitbox = entities.add_edges pt[0], pt[1], pt[2], pt[3], pt[0], pt[4], pt[5], pt[1]
limitbox = entities.add_edges pt[5], pt[6], pt[2]
limitbox = entities.add_edges pt[6], pt[7], pt[3]
limitbox = entities.add_edges pt[7], pt[4]
end

def save_file(inputname)
#*******************************
#
#The purpose of this method is to save the file. Dialog to get filename then save it
#
#*******************************

	# Handle for the model
	model = Sketchup.active_model

	# Actually perform save operation
	filename = File.join('C:\Github', 'Composite-Percolation', inputname)
	status = model.save(filename)
	
	return inputname

end