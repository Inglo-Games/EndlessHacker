extends Block
class_name PowerupBlock

signal powerup_gained

enum POWER_TYPE{
	CALC,
	CASSETTE,
	FLOPPY,
	PHONE
}

var powerup_type = POWER_TYPE.CALC

func _ready():
	
	powerup_type = randi() % 4
	
	match(powerup_type):
		POWER_TYPE.CALC:
			$powerup_calc.visible = true
			$powerup_calc/area.connect("body_entered", self, "_on_body_entered")
		POWER_TYPE.CASSETTE:
			$powerup_cassette.visible = true
			$powerup_cassette/area.connect("body_entered", self, "_on_body_entered")
		POWER_TYPE.FLOPPY:
			$powerup_floppy.visible = true
			$powerup_floppy/area.connect("body_entered", self, "_on_body_entered")
		POWER_TYPE.PHONE:
			$powerup_phone.visible = true
			$powerup_phone/area.connect("body_entered", self, "_on_body_entered")

# Emit signal that player has gained this powerup
func _on_body_entered(body):
	if body is Player:
		emit_signal("powerup_gained", powerup_type)
		$AnimationPlayer.stop()
		$particles.emitting = true
		$powerup_calc.queue_free()
		$powerup_cassette.queue_free()
		$powerup_floppy.queue_free()
		$powerup_phone.queue_free()
