extends KinematicBody2D

const MAX_SPEED = 500
const ACCEL = 10
const GRAVITY = 20

var left = true
var angle = 0
var mult

var movable = true

var motion = Vector2(0,0)

func _ready():
	pass

func _physics_process(delta):
	if movable:
		motion.x = abs(motion.x)
		if motion.x < MAX_SPEED:
			motion.x += ACCEL
		else:
			motion.x = MAX_SPEED
		if left:
			motion.x *= -1
				
		motion.y = lerp(motion.y, GRAVITY, 0.05)
		if !left:
			$Sprite.flip_h = true
			$Collider.scale.x = -1
			$RayCast2D.cast_to.x *= -1
	else:
		motion.x = 0
		motion.y = GRAVITY * 20
	
	if $RayCast2D.is_colliding():
		movable = false
		motion.x = 0
	
	if Input.is_action_just_pressed("ui_switch"):
		global_position.y -= 50
		globs.transform_harry()
	
	move_and_slide(motion)