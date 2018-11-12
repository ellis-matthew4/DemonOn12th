extends Node2D

var office = preload("res://office.tscn")
var menu = preload("res://assets/scenes/Menu.tscn")

var scene

func _ready():
	scene = menu.instance()
	scene.connect("Switch", self, "switch")
	add_child(scene)
	
func switch():
	var x = load(globs.path)
	remove_child(scene)
	scene = x.instance()
	scene.connect("Switch", self, "switch")
	add_child(scene)