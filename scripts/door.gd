extends Node2D

export(Vector2) var warpPoint
var ready = false
var p

var fade = preload("res://assets/shaders/TransitionFade.tscn")

signal door_passage

func _ready():
	set_process(true)
func _process(delta):
	if ready:
		if Input.is_action_just_pressed("ui_select"):
			var f = fade.instance()
			add_child(f)
			f.connect("faded", self, "fade")

func _on_doorArea_body_entered(body):
	p = body
	ready = true

func _on_doorArea_body_exited(body):
	ready = false
	
func fade():
	p.global_position = warpPoint
	emit_signal("door_passage")