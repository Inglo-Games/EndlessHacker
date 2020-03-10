extends Spatial

signal score_updated

var score := 0.0
var score_mult := 1.0
var autowins := 0

func _ready():
	$player.connect("lives_updated", $gui, "_on_update_lives")
	connect("score_updated", $gui, "_on_update_score")

func _process(delta):
	score += delta * score_mult
	emit_signal("score_updated", score)

# Function that triggers when a player gains a powerup
func activate_powerup(powerup_type : int):
	
	match(powerup_type):
		
		PowerupBlock.POWER_TYPE.FLOPPY:
			$player.gain_life()
		
		PowerupBlock.POWER_TYPE.CALC:
			score_mult = 2.5
			yield(get_tree().create_timer(5.0), "timeout")
			score_mult = 1.0
		
		PowerupBlock.POWER_TYPE.CASSETTE:
			autowins += 1
		
		PowerupBlock.POWER_TYPE.PHONE:
			# TODO: Implement time slowing
			continue

# Generate a new block and removed passed blocks after a set time
func _on_timer_timeout():
	$blocks.gen_block()
	$blocks.clean_blocks()
