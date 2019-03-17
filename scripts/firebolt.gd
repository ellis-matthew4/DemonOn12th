extends KinematicBody2D

var SPEED = 500
const EXPLOSION = preload("res://assets/scenes/DamagelessExplosion.tscn")
var damage = 2
const BOOST = false
var motion = Vector2(0,0)

func _ready():
	set_process(true)

func _process(delta):
	$Sprite.rotation = $Sprite.rotation + deg2rad(-90 * delta) * 300
	move_and_slide(motion)
	
func orient(direction):
	motion = direction * Vector2(SPEED,SPEED)
	$Particles2D.process_material.gravity = Vector3(-direction.x, -direction.y, 0)

func _on_Timer_timeout():
	var bomb = EXPLOSION.instance()
	get_parent().add_child(bomb)
	bomb.global_position = self.global_position
	queue_free()

func _on_Source_body_entered(body):
	if body.has_method("damage"):
		body.damage(self, damage)
	_on_Timer_timeout()