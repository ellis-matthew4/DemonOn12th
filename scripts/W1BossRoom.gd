extends Node2D

onready var bossScene = preload("res://assets/scenes/Shikigami.tscn")
onready var positions = [ $Position2D.global_position, $Position2D2.global_position, $Position2D3.global_position,
						  $Position2D4.global_position, $Position2D5.global_position]

func _ready():
	randomize()
	
func getPos():
	return positions[randi() % 5]
	
func spawnBoss():
	var k = bossScene.instance()
	k.global_position = positions[4]
	add_child(k)
	yield(k, "dead")
	get_node("../../midground/Mirror3").global_position -= Vector2(0,1000)