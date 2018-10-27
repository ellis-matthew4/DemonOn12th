extends KinematicBody2D

var SPEED = 30
const JUMP_HEIGHT = 350
const UP = Vector2(0, -1)

var moving = true
var motion = Vector2()
var jumping = false

onready var sprite = $body/slime

func _ready():
	randomize()
	set_process(true)

func _process(delta):
	var collision = move_and_collide(motion * delta)
	if collision:
		SPEED *= -1
			
	motion.x = SPEED
	
	motion = move_and_slide(motion)