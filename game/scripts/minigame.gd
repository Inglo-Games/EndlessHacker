extends Control
class_name Minigame

signal cassette_used
signal game_won
signal game_lost

func _ready():
	$vbox/win_btn.connect("button_up", self, "_on_minigame_won")
	$vbox/lose_btn.connect("button_up", self, "_on_minigame_lost")
	$vbox/skip_btn.connect("button_up", self, "_on_minigame_skipped")

func _on_minigame_won():
	emit_signal("game_won")

func _on_minigame_lost():
	emit_signal("game_lost")

func _on_minigame_skipped():
	emit_signal("cassette_used")
