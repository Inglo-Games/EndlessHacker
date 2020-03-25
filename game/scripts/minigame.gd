extends Control
class_name Minigame

signal game_won
signal game_lost

func _on_minigame_won():
	emit_signal("game_won")

func _on_minigame_lost():
	emit_signal("game_lost")
