extends Node2D

const EXPLOSION = preload("res://assets/scenes/explosion.tscn")

func _ready():
	set_process(true)
	
func _process(delta):
	$Sprite.rotation = $Sprite.rotation + deg2rad(-90 * delta)
	if Input.is_key_pressed(KEY_SPACE):
		if !get_parent().find_node("player").crouch:
			detonate()

func detonate():
	var bomb = EXPLOSION.instance()
	get_parent().add_child(bomb)
	bomb.global_position = self.global_position
	get_parent().remove_child(self)