extends Block

signal player_collided

func _ready():
	$player_collide_area.connect("body_entered", self, "_on_body_entered")

# Triggered when a body enters the obstacle area, marked by particles
func _on_body_entered(body):
	if body is Player:
		emit_signal("player_collided")
