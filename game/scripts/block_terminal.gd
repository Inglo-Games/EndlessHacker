extends Block

signal minigame_triggered

func _ready():
	$player_collide_area.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body is Player:
		print("Minigame triggered")
		emit_signal("minigame_triggered")
