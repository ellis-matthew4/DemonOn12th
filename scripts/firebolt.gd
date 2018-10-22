extends RigidBody2D

var FIREBALL_SPEED = 300
const EXPLOSION = preload("res://assets/scenes/explosion.tscn")

func _ready():
	set_process(true)
	apply_impulse(Vector2(), Vector2(FIREBALL_SPEED, 0))

func _process(delta):
	$Sprite.rotation = $Sprite.rotation + deg2rad(-90 * delta) * 300
	
func orient(left):
	if left:
		FIREBALL_SPEED *= -1
		$Particles2D.process_material.gravity = Vector3(-100, 0, 0)
	else:
		$Particles2D.process_material.gravity = Vector3(100,0,0)

func _on_Timer_timeout():
	var bomb = EXPLOSION.instance()
	get_parent().add_child(bomb)
	bomb.global_position = self.global_position
	get_parent().remove_child(self)
