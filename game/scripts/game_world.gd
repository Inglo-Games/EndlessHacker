extends Spatial

signal score_updated

const CAM_RUNNER_POS := Vector3(0, 2, 10)
const CAM_MINIGAME_POS := Vector3(-0.2, 1.9, -0.2)
const MINIGAME_WIN_BONUS := 100.0

onready var tween := $tween

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
			slow_game(0.5, 0.33)
			$powerup_timer.connect("timeout", self, "resume_speed", [0.33])
			$powerup_timer.start(8.0)

# Stop the runner portion of the game and move the camera to show the minigame
func show_minigame():
	slow_game(0.0, 0.65)
	tween.interpolate_property($camera, "translation", CAM_RUNNER_POS, 
				CAM_MINIGAME_POS, 0.35, Tween.TRANS_CUBIC, Tween.EASE_OUT)

# Reset camera to original position and resume game
func end_minigame():
	resume_speed(0.65)
	tween.interpolate_property($camera, "translation", CAM_MINIGAME_POS, 
				CAM_RUNNER_POS, 0.35, Tween.TRANS_CUBIC, Tween.EASE_OUT)

# Slow movement of blocks and player to target percentage
func slow_game(target:float, speed:float):
	tween.interpolate_property($blocks, "scroll_speed_mult", 1.0, target, 
				speed, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property($player, "anim:playback_speed", 1.0, target,
				speed, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(self, "score_mult", score_mult, target,
				speed, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

# Speed blocks and players back up to normal speed
func resume_speed(speed:float):
	tween.interpolate_property($blocks, "scroll_speed_mult", 0.0, 1.0, 
				speed, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.interpolate_property($player, "anim:playback_speed", 0.0, 1.0,
				speed, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.interpolate_property(self, "score_mult", score_mult, 1.0,
				speed, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()

# Generate a new block and removed passed blocks after a set time
func _on_timer_timeout():
	$blocks.gen_block()
	$blocks.clean_blocks()

func _on_minigame_won():
	score += MINIGAME_WIN_BONUS
	end_minigame()

func _on_minigame_lost():
	$player.lose_life()
	end_minigame()
