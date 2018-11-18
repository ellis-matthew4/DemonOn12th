extends KinematicBody2D

const MAX_SPEED = 500
const ACCEL = 30
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
		if left:
			if angle > -30 or angle < 30:
				mult = (angle + 30)/60
				if motion.x < MAX_SPEED:
					motion.x += MAX_SPEED
				else:
					motion.x = MAX_SPEED
			elif angle > 30:
				var m = (angle-30)/60
				mult = -m * 2
				if motion.x > 0:
					motion.x = lerp(motion.x, 0, m)
				else:
					motion.x = 0
			else:
				var m = abs((angle+30)/60)
				mult = m + 0.3
				if motion.x < MAX_SPEED:
					motion.x = lerp(0,MAX_SPEED,m)
				else:
					motion.x = MAX_SPEED
			motion.x *= -1
		else:
			if angle > -30 or angle < 30:
				mult = (angle + 30)/60
				if motion.x < MAX_SPEED:
					motion.x += MAX_SPEED
				else:
					motion.x = MAX_SPEED
			elif angle < -30:
				var m = (angle-30)/60
				mult = -m * 2
				if motion.x > 0:
					motion.x = lerp(motion.x, 0, m)
				else:
					motion.x = 0
			else:
				var m = abs((angle+30)/60)
				mult = m + 0.3
				if motion.x < MAX_SPEED:
					motion.x = lerp(0,MAX_SPEED,m)
				else:
					motion.x = MAX_SPEED				
		motion.y = (mult+1) * GRAVITY
		
	if !left:
		$Sprite.flip_h = true
		$Collider.scale.x = -1
		if Input.is_action_pressed("ui_left"):
			if angle > -90:
				angle -= ACCEL * delta
		if Input.is_action_pressed("ui_right"):
			if angle < 90:
				angle += ACCEL * delta
	else:
		$Sprite.flip_h = false
		if Input.is_action_pressed("ui_left"):
			if angle < 90:
				angle += ACCEL * delta
		if Input.is_action_pressed("ui_right"):
			if angle > -90:
				angle -= ACCEL * delta
	rotation_degrees = angle
	
	if $RayCast2D.is_colliding():
		movable = false
		motion.x = 0
	
	if Input.is_action_just_pressed("ui_switch"):
		global_position.y -= 50
		globs.transform_harry()
	
	move_and_slide(motion)