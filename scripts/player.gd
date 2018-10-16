extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 20
const ACCELERATION = 50
const MAX_SPEED = 200
const JUMP_HEIGHT = 550
const LADDER_SPEED = 300

var motion = Vector2()
var jumping = false
var on_ladder = false

func _physics_process(delta):
	var tilemap = get_parent()
	
	if on_ladder:
		if Input.is_action_pressed("ui_up"):
			motion.y = -LADDER_SPEED
		elif Input.is_action_pressed("ui_down"):
			motion.y = LADDER_SPEED
		else:
			motion.y = 0
	else:
		motion.y += GRAVITY
	
	if Input.is_action_pressed("ui_right"):
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
		$Sprite.flip_h = false
		$Sprite.play("walk")
		$Sprite.playing = true
	elif Input.is_action_pressed("ui_left"):
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		$Sprite.flip_h = true
		$Sprite.play("walk")
		$Sprite.playing = true
	else:
		$Sprite.frame = 0
		$Sprite.playing = false
		motion.x = 0
		
	if Input.is_key_pressed(KEY_F):
		get_node("../../MagicCircle/spell").activate()
	if Input.is_key_pressed(KEY_R):
		get_node("../../MagicCircle/spell").deactivate()
		
	if not tilemap == null:
		var id = tilemap.get_cellv(tilemap.world_to_map(position))
		if id > -1:
			if tilemap.get_tileset().tile_get_name(id) == "ladder":
				on_ladder = true
			else:
				on_ladder = false
		else:
			on_ladder = false
		
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			motion.y = -JUMP_HEIGHT
			
	motion = move_and_slide(motion, UP)
	pass
			