extends Control
class_name Minigame

signal cassette_used
signal game_won
signal game_lost

func _ready():
	$instructions/vbox/hbox/run_btn.connect("button_up", self, "_on_minigame_executed")
	$instructions/vbox/hbox/skip_btn.connect("button_up", self, "_on_minigame_skipped")

# Virtual function to be overwritten by minigames
func start_minigame():
	pass

func _on_minigame_won():
	emit_signal("game_won")

func _on_minigame_lost():
	emit_signal("game_lost")

func _on_minigame_executed():
	$instructions.visible = false
	start_minigame()

func _on_minigame_skipped():
	emit_signal("cassette_used")
