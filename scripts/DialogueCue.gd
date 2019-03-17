extends Area2D

signal cue

func _ready():
	connect("body_entered", self, "tryCue")
	
func tryCue(body):
	if body.is_in_group("playable_characters"):
		emit_signal("cue")
		queue_free()