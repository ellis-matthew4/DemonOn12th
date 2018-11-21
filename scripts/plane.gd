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
	
	if movable:
		if !left:
			$Sprite.flip_h = true
			$Collider.scale.x = -1
#			if Input.is_action_pressed("ui_left"):
#				if angle > -90:
#					angle -= ACCEL * delta
#			if Input.is_action_pressed("ui_right"):
#				if angle < 90:
#					angle += ACCEL * delta
#		else:
#			$Sprite.flip_h = false
#			if Input.is_action_pressed("ui_left"):
#				if angle < 90:
#					angle += ACCEL * delta
#			if Input.is_action_pressed("ui_right"):
#				if angle > -90:
#					angle -= ACCEL * delta
#		$Sprite.rotation_degrees = angle
#		$Collider.rotation_degrees = angle
	
	if $RayCast2D.is_colliding():
		movable = false
		motion.x = 0
	
	if Input.is_action_just_pressed("ui_switch"):
		global_position.y -= 50
		globs.transform_harry()
	
	move_and_slide(motion)