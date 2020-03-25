extends Minigame

func _ready():
	var world = get_node("/root/game_world")
	if world.autowins <= 0:
		$VBoxContainer/Button3.disabled = true
