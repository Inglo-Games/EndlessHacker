extends Spatial

onready var lives_label = $Viewport/Control/HBoxContainer/lives_label
onready var score_label = $Viewport/Control/HBoxContainer/score_label

func _ready():
	pass

func _on_update_lives(new_num : int):
	lives_label.text = "Logins: %d" % new_num

func _on_update_score(new_score : float):
	score_label.text = "dl: %.2f kb" % new_score
