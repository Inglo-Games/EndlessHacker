extends Control
class_name Minigame

signal game_won
signal game_lost

func _ready():
	$vbox/win_btn.connect("button_up", self, "_on_minigame_won")
	$vbox/lose_btn.connect("button_up", self, "_on_minigame_lost")

func set_skip_btn(cassettes:int):
	$vbox/skip_btn.disabled = (cassettes == 0)

func _on_minigame_won():
	emit_signal("game_won")

func _on_minigame_lost():
	emit_signal("game_lost")

func get_class(): return "Minigame"
