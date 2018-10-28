extends KinematicBody2D

export var SPEED = 30
const GRAVITY = 20
var motion = Vector2()
var damaged = false
var dying = false

onready var sprite = $slime
onready var ray = $RayCast2D

func _ready():
	set_process(true)

func _process(delta):
	if dying:
		motion.y += GRAVITY
		if !is_on_floor():
			rotation += 0.1
	if ray.is_colliding():
		ray.cast_to.x *= -1
		SPEED *= -1
		sprite.flip_h = !sprite.flip_h
	motion.x = SPEED
	if damaged:
		motion.x = 0
		motion.y = -400
		damaged = false
		dying = true
	motion = move_and_slide(motion)
	
func damage(obj, damage):
	damaged = true
	$deathTimer.start()

func _on_deathTimer_timeout():
	queue_free()

func entered_hitbox(body):
	if body.is_in_group("playable_characters"):
		body.damage(self, -1)