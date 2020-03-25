extends Block

signal minigame_triggered

onready var term_viewport = $terminal_block/Viewport
onready var screen_quad = $terminal_block/screen_quad
onready var screen_area = $terminal_block/screen_quad/area

var quad_mesh_size := Vector2.ZERO
var is_mouse_inside := false
var is_mouse_held := false
var last_mouse_pos3D = null
var last_mouse_pos2D = null

func _ready():
	$terminal_block/screen_quad/area.connect("mouse_entered", self, "_on_mouse_entered")
	$player_collide_area.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body is Player:
		print("Minigame triggered")
		emit_signal("minigame_triggered")

func _on_mouse_entered():
	is_mouse_inside = true

# Function taken from the "GUI in 3D" demo project
func _input(event):
	
	var is_mouse_event = false
	for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
		if event is mouse_event:
			is_mouse_event = true
			break
	
	if is_mouse_event and (is_mouse_inside or is_mouse_held):
		handle_mouse(event)
	elif not is_mouse_event:
		term_viewport.input(event)

# Function taken from the "GUI in 3D" demo project
func handle_mouse(event):
	
	# Detect mouse being held to mantain event while outside of bounds. Avoid orphan clicks
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		is_mouse_held = event.pressed
	
	# Find mouse position in Area
	var mouse_pos3D = find_mouse(event.global_position)
	
	# Check if the mouse is outside of bounds, use last position to avoid errors
	# NOTE: mouse_exited signal was unrealiable in this situation
	is_mouse_inside = mouse_pos3D != null
	if is_mouse_inside:
		# Convert click_pos from world coordinate space to a coordinate space relative to the Area node.
		# NOTE: affine_inverse accounts for the Area node's scale, rotation, and translation in the scene!
		mouse_pos3D = screen_area.global_transform.affine_inverse() * mouse_pos3D
		last_mouse_pos3D = mouse_pos3D
	else:
		mouse_pos3D = last_mouse_pos3D
		if mouse_pos3D == null:
			mouse_pos3D = Vector3.ZERO
	
	# convert the relative event position from 3D to 2D
	var mouse_pos2D = Vector2(mouse_pos3D.x, -mouse_pos3D.y)
	
	# Get mesh size to detect edges and make conversions. This code only support PlaneMesh and QuadMesh.
	quad_mesh_size = screen_quad.mesh.size
	# Right now the event position's range is the following: (-quad_size/2) -> (quad_size/2)
	mouse_pos2D.x += quad_mesh_size.x / 2
	mouse_pos2D.y += quad_mesh_size.y / 2
	mouse_pos2D.x = mouse_pos2D.x / quad_mesh_size.x
	mouse_pos2D.y = mouse_pos2D.y / quad_mesh_size.y
	mouse_pos2D.x = mouse_pos2D.x * term_viewport.size.x
	mouse_pos2D.y = mouse_pos2D.y * term_viewport.size.y
	
	# Set the event's position and global position.
	event.position = mouse_pos2D
	event.global_position = mouse_pos2D
	
	# If the event is a mouse motion event...
	if event is InputEventMouseMotion:
		if last_mouse_pos2D == null:
			event.relative = Vector2(0, 0)
		else:
			event.relative = mouse_pos2D - last_mouse_pos2D
	last_mouse_pos2D = mouse_pos2D
	
	term_viewport.input(event)

# Function taken from the "GUI in 3D" demo project
func find_mouse(global_position):
	var camera = get_viewport().get_camera()
	
	# From camera center to the mouse position in the Area
	var from = camera.project_ray_origin(global_position)
	var dist = find_further_distance_to(camera.transform.origin)
	var to = from + camera.project_ray_normal(global_position) * dist
	
	# Manually raycasts the are to find the mouse position
	var result = get_world().direct_space_state.intersect_ray(from, to, [], 
				screen_area.collision_layer,false,true) 
	
	if result.size() > 0:
		return result.position
	else:
		return null

# Function taken from the "GUI in 3D" demo project
func find_further_distance_to(origin):
	# Find edges of collision and change to global positions
	var edges = []
	edges.append(screen_area.to_global(Vector3(quad_mesh_size.x / 2, quad_mesh_size.y / 2, 0)))
	edges.append(screen_area.to_global(Vector3(quad_mesh_size.x / 2, -quad_mesh_size.y / 2, 0)))
	edges.append(screen_area.to_global(Vector3(-quad_mesh_size.x / 2, quad_mesh_size.y / 2, 0)))
	edges.append(screen_area.to_global(Vector3(-quad_mesh_size.x / 2, -quad_mesh_size.y / 2, 0)))
	
	# Get the furthest distance between the camera and collision to avoid raycasting too far or too short
	var far_dist = 0
	var temp_dist
	for edge in edges:
		temp_dist = origin.distance_to(edge)
		if temp_dist > far_dist:
			far_dist = temp_dist
	
	return far_dist
