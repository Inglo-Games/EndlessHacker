extends Control
class_name Minigame

signal cassette_used
signal game_won
signal game_lost

func _ready():
	$instructions/vbox/hbox/run_btn.connect("button_up", self, "_on_minigame_executed")
	$instructions/vbox/hbox/skip_btn.connect("button_up", self, "_on_minigame_skipped")
	
	$minigame/vbox/win_btn.connect("button_up", self, "_on_minigame_won")
	$minigame/vbox/lose_btn.connect("button_up", self, "_on_minigame_lost")

func _on_minigame_won():
	emit_signal("game_won")

func _on_minigame_lost():
	emit_signal("game_lost")

func _on_minigame_executed():
	$instructions.visible = false
	$minigame/vbox/win_btn.grab_focus()

func _on_minigame_skipped():
	emit_signal("cassette_used")
