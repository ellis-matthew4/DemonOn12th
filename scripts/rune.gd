extends Node2D

const EXPLOSION = preload("res://assets/scenes/explosion.tscn")

func _ready():
	set_process(true)
	
func _process(delta):
	$Sprite.rotation = $Sprite.rotation + deg2rad(-90 * delta)
	if Input.is_key_pressed(KEY_SPACE):
		var k = get_node("../Characters").get_child(0)
		if k.CHAR != "John": 
			detonate()
		if !k.crouch:
			detonate()

func detonate():
	var bomb = EXPLOSION.instance()
	get_parent().add_child(bomb)
	bomb.global_position = self.global_position
	queue_free()