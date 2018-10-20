extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 20
const ACCELERATION = 50
const MAX_SPEED = 200
const JUMP_HEIGHT = 550
const LADDER_SPEED = 300
const FIREBOLT_SCENE = preload("res://assets/scenes/firebolt.tscn")

var motion = Vector2()
var jumping = false
var on_ladder = false
var left = false
var cooldown = false

func _ready():
	set_process(true)
	
func _process(delta):
	if !cooldown:
		if Input.is_key_pressed(KEY_SPACE):
			var fb = FIREBOLT_SCENE.instance()
			fb.orient(left)
			get_parent().add_child(fb)
			fb.position = $Sprite/projectilePos.global_position
			cooldown = true
			$ProjectileTimer.start()

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
		if left:
			$Sprite/projectilePos.position *= Vector2(-1,1)
		$Sprite.play("walk")
		$Sprite.playing = true
		left = false
	elif Input.is_action_pressed("ui_left"):
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		$Sprite.flip_h = true
		if !left:
			$Sprite/projectilePos.position *= Vector2(-1,1)
		$Sprite.play("walk")
		$Sprite.playing = true
		left = true
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

func _on_ProjectileTimer_timeout():
	cooldown = false
