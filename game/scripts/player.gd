extends KinematicBody
class_name Player

signal lives_updated

const GRAVITY := Vector3(0, -64.0, 0)
const INIT_POSITION := Vector3(0, 3, 0)
const JUMP_VELOCITY := 20.5
const Y_THRESHOLD := -5.0

onready var anim := $AnimationPlayer

var velocity := Vector3()
var lives_remaining := 3
var is_immune := false
var is_sliding := false

func _ready():
	move_lock_x = true
	move_lock_z = true
	anim.play("Run")

func _process(delta : float):
	
	# Detect falling
	if translation.y < Y_THRESHOLD:
		lose_life()
		translation = INIT_POSITION
		velocity = Vector3.ZERO
	
	velocity += delta * GRAVITY
	velocity = move_and_slide(velocity, Vector3.UP)
	
	if(Input.is_action_just_pressed("jump") and is_on_floor()):
		normal_position()
		velocity.y += JUMP_VELOCITY
	elif(Input.is_action_just_pressed("slide")):
		slide_position()

# Function to start the sliding animation and adjust collision shape
func slide_position():
	if not is_sliding:
		anim.play("Idle")
		is_sliding = true
		scale.y = 0.2
		yield(get_tree().create_timer(0.6), "timeout")
		normal_position()

# Function to return to running animation
func normal_position():
	anim.play("Run")
	is_sliding = false
	scale.y = 0.4

# Function triggers when a life is lost
func lose_life():
	if not is_immune:
		lives_remaining -= 1
		
		# TODO: Implement game over popup
		if lives_remaining <= 0:
			get_tree().quit()
		
		# Show damage animation
		emit_signal("lives_updated", lives_remaining)
		glitch_out()
		
		# Make player invincible for a short time
		is_immune = true
		yield(get_tree().create_timer(2.4), "timeout")
		is_immune = false

# Function triggered when life is gained
func gain_life():
	lives_remaining += 1
	emit_signal("lives_updated", lives_remaining)

# Function that triggers the visual damage shader
func glitch_out():
	var mat = get_node("armature/mesh").get_surface_material(0)
	$Tween.interpolate_property(mat, "shader_param/glitch_amount", 
			1.0, 0.0, 2.4, 
			Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	$Tween.start()
