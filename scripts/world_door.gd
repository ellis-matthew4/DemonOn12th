extends Node2D

export var path = "path_to_scene"
var ready = false
var p
signal Switch

func _ready():
	set_process(true)
func _process(delta):
	if ready:
		if Input.is_action_just_pressed("ui_select"):
			fade()

func _on_doorArea_body_entered(body):
	p = body
	ready = true

func _on_doorArea_body_exited(body):
	ready = false

func fade():
	globs.path = path
	emit_signal("Switch")