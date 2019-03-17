extends Node2D

var menu = preload("res://assets/scenes/Menu.tscn")
var scene

func _ready():
	scene = menu.instance()
	scene.connect("Switch", self, "switch")
	add_child(scene)
	
func switch():
	globs.removeCam()
	var x = load(globs.path)
	remove_child(scene)
	scene.queue_free()
	scene = x.instance()
	scene.connect("Switch", self, "switch")
	add_child(scene)