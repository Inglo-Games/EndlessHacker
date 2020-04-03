extends Control

onready var lives_label = $hbox/lives_label
onready var score_label = $hbox/score_label

func _on_update_lives(new_num : int):
	lives_label.text = "Logins: %d" % new_num

func _on_update_score(new_score : float):
	score_label.text = "dl: %.2f kb" % new_score
