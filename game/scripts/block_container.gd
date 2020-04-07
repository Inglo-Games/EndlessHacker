extends Spatial

const SCROLL_SPEED := 0.15
const LEFT_EDGE_DIST := -16.0
const BLOCK_WIDTH := Vector3(6, 0, 0)

# This defines probabilities for each block to transition to the next
# E.g., the probability block A is followed by block B is TRANS_PROBS[A][B]
const TRANS_PROBS := [
	[0.0,  0.3,  0.3, 0.25, 0.05, 0.1],
	[0.3,  0.2,  0.3, 0.2,  0,    0],
	[0.3,  0.5,  0.1, 0,    0,    0.1],
	[0.75, 0.15, 0,   0.05, 0.05, 0],
	[0.6,  0.1,  0.1, 0.2,  0,    0],
	[1.0,  0,    0,   0,    0,    0]
]

enum BLOCK_TYPES{
	BLOCK_FLAT,
	BLOCK_HIGH,
	BLOCK_LOW,
	BLOCK_GAP,
	BLOCK_POWERUP,
	BLOCK_MINIGAME
}

onready var Choice = preload("res://scripts/choice.gd")
onready var block_scenes = [
	preload("res://scenes/blocks/block_template.tscn"),
	preload("res://scenes/blocks/block_high_obstacle.tscn"),
	preload("res://scenes/blocks/block_low_obstacle.tscn"),
	preload("res://scenes/blocks/block_gap.tscn"),
	preload("res://scenes/blocks/block_powerup.tscn"),
	preload("res://scenes/blocks/block_terminal.tscn")
]

onready var player := get_node("/root/game_world/player")
onready var world := get_node("/root/game_world")

# State variables
var alive := true
var scroll_speed_mult := 1.0
var last_block_pos := Vector3(0, 0, 0)
var last_block_type := 0

func _ready():
	
	# Initialize state vars
	last_block_pos = get_children()[-1].translation

func _process(_delta):
	global_translate(Vector3(-SCROLL_SPEED, 0.0, 0.0) * scroll_speed_mult)

# Add a new block to the world on the far right
func gen_block():
	
	# Instance a new block and add it to the world
	var block_type = Choice.pick_int(TRANS_PROBS[last_block_type])
	var new_block = block_scenes[block_type].instance()
	new_block.translation = last_block_pos + BLOCK_WIDTH
	add_child(new_block)
	last_block_type = block_type
	last_block_pos = new_block.translation
	
	# Connect any signals in the block
	match(block_type):
		BLOCK_TYPES.BLOCK_HIGH:
			new_block.connect("player_collided", player, "lose_life")
		BLOCK_TYPES.BLOCK_LOW:
			new_block.connect("player_collided", player, "lose_life")
		BLOCK_TYPES.BLOCK_POWERUP:
			new_block.connect("powerup_gained", world, "activate_powerup")
		BLOCK_TYPES.BLOCK_MINIGAME:
			new_block.connect("minigame_triggered", world, "show_minigame")
			new_block.get_node("terminal_block/Viewport/minigame_frame").connect("game_won", world, "_on_minigame_won")
			new_block.get_node("terminal_block/Viewport/minigame_frame").connect("game_lost", world, "_on_minigame_lost")
			new_block.get_node("terminal_block/Viewport/minigame_frame").connect("cassette_used", world, "_on_minigame_skipped")

# Remove blocks that have passed the left edge of the screen
func clean_blocks():
	var all_blocks = get_children()
	while(all_blocks[0].global_transform.origin.x < LEFT_EDGE_DIST):
		var left_block = all_blocks[0]
		all_blocks.remove(0)
		left_block.queue_free()
