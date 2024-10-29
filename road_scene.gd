extends Node2D

var camera_height = 1000 #world height of the camera
var camera_distance = 0.0; # distance of camera from screen
var segment_size = 200 #z length of a signel road segment
var segments_num = 500 #number of road segments
var draw_distance = 200 #number of road segments to render each frame
var FOV = 60 #field of view used to compute camera distance
var window_width = 0
var window_height = 0
var player_position = 0 # position of player to begin rendering from
var player_x = 0

var road_width = 2000 # real road width / 2

class point: # each point contains 2 vectors to represent thier screen and world positions
	var world = Vector3(0,0,0) # generated when the segement is first created
	var screen = Vector3(0,0,0) # computed when the segment must be rendered

class segment: #eac segment is represetned by two points p1 (lower edge) and p2 (upper edge)
	var p1 = point.new()       
	var p2 = point.new()
	var index # index of 
	
	#     ------(p2)-------
	#    -                 -
	#   -                   -
	#   --------(p1)----------

var points = [] #array of array of points in polygons to render each frame
var segments = [] # list of all segments in road



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#find width and height of window
	window_width = self.get_viewport_rect().size.x 
	window_height = self.get_viewport_rect().size.y
	#compute distance from screen according to FOV
	camera_distance =1/tan(deg_to_rad(FOV/2.0))
	# generate segments
	for i in range(segments_num):
		var s = segment.new()
		s.p1.world = Vector3(0,0,i*segment_size)
		s.p2.world = Vector3(0,0,(i+1)*segment_size) 		
		s.index = i
		segments.push_back(s)
		
# compute projection of point world vector to point screen vector
func world_to_screen(p: point, camera_x: float, camera_y:float, camera_z: float):
	var camera_p = p.world - Vector3(camera_x,camera_y,camera_z) #effectviely makes camera always at origin for computation
	var screen_scale = float(camera_distance) / camera_p.z       #screen scale of world/screen
	p.screen.x = (window_width/2) + (screen_scale * camera_p.x * window_width/2) 
	p.screen.y = (window_height/2) - (screen_scale * camera_p.y * window_height/2)
	p.screen.z = (screen_scale * road_width * (window_width/2)) # width of road/2 on screen



func _draw():
	for a in points:
		draw_colored_polygon(a,Color.RED)
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#clear rendered polygons each frame
	points = []
	# draw only what is within our draw distance
	# TO-DO calc first segment and draw from there
	for i in range(draw_distance):
		var s = segments[i]
		#project segment points to screen space
		world_to_screen(s.p1,road_width*player_x,camera_height,player_position)
		world_to_screen(s.p2,road_width*player_x,camera_height,player_position)
		#clip if segement is behind camera
		if (s.p1.world.z - player_position <= camera_distance):
			continue;
		#add polygon vectors to be drawn
		points.append(PackedVector2Array([Vector2(s.p1.screen.x + (s.p1.screen.z),s.p1.screen.y), 
										  Vector2(s.p1.screen.x - (s.p1.screen.z),s.p1.screen.y),
										  Vector2(s.p2.screen.x - (s.p2.screen.z),s.p2.screen.y), 
										  Vector2(s.p2.screen.x + (s.p2.screen.z),s.p2.screen.y)]))
		queue_redraw()
		
