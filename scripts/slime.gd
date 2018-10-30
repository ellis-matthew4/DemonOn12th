extends RigidBody2D

export var SPEED = 180
export var JUMP = -200
const GRAVITY = 20
const DEATH = preload("res://assets/scenes/SlimeDeath.tscn")
var motion = Vector2(SPEED, JUMP)

onready var sprite = $slime
onready var ray = $RayCast2D

func _ready():
	$jump.start()
	set_process(true)

func _process(delta):
	if ray.is_colliding():
		ray.cast_to.x *= -1
		SPEED *= -1
		sprite.flip_h = !sprite.flip_h
	
func damage(obj, damage):
	var k = DEATH.instance()
	get_parent().add_child(k)
	k.global_position = global_position
	queue_free()

func entered_hitbox(body):
	if body.is_in_group("playable_characters"):
		body.damage(self, -1)

func _on_jump_timeout():
	motion = Vector2(SPEED, JUMP)
	apply_impulse(Vector2(), motion)
	$jump.start()
