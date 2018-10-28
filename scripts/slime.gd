extends KinematicBody2D

var SPEED = 30
const JUMP_HEIGHT = 350
const UP = Vector2(0, -1)
const GRAVITY = 20

var moving = true
var motion = Vector2()
var jumping = false
var damaged = false
var dying = false

onready var sprite = $slime

func _ready():
	randomize()
	set_process(true)

func _process(delta):
	if dying:
		motion.y += GRAVITY
		if !is_on_floor():
			rotation += 0.1
	var collision = move_and_collide(motion * delta)
	if collision:
		SPEED *= -1
		$slime.flip_h = !$slime.flip_h
			
	motion.x = SPEED
	
	if damaged:
		motion.x = 400
		motion.y = -JUMP_HEIGHT
		damaged = false
		dying = true
	
	motion = move_and_slide(motion)
	
func damage(obj, damage):
	damaged = true
	$deathTimer.start()

func _on_deathTimer_timeout():
	queue_free()
