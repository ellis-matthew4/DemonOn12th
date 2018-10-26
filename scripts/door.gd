extends Node2D

export(Vector2) var warpPoint
var ready = false
var p

func _ready():
	set_process(true)
func _process(delta):
	if ready:
		if Input.is_action_just_pressed("ui_select"):
			p.global_position = warpPoint

func _on_doorArea_body_entered(body):
	p = body
	ready = true

func _on_doorArea_body_exited(body):
	ready = false