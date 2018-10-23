extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 20
const ACCELERATION = 50
const MAX_SPEED = 200
const JUMP_HEIGHT = 550
const LADDER_SPEED = 300
const CHAR = "John"
const FIREBOLT_SCENE = preload("res://assets/scenes/firebolt.tscn")
const RUNE_SCENE = preload("res://assets/scenes/rune.tscn")
const NEXT_CHAR = preload("res://assets/scenes/player_harry.tscn")

var motion = Vector2()
var jumping = false
var on_ladder = false
var left = false
var cooldown = false
var crouch = false

onready var col = get_node("Collider")
onready var ocl = get_node("Sprite/LightOccluder2D")
onready var tilemap = get_tree().current_scene.find_node("midground")

func _ready():
	set_process(true)
	
func _process(delta):
	if !cooldown:
		if Input.is_action_just_pressed("ui_attack"):
			if !crouch:
				var fb = FIREBOLT_SCENE.instance()
				fb.orient(left)
				tilemap.add_child(fb)
				fb.position = $Sprite/projectilePos.global_position
				cooldown = true
				$ProjectileTimer.start()
			else:
				var rn = RUNE_SCENE.instance()
				tilemap.add_child(rn)
				rn.global_position = $Sprite/projectilePos.global_position

func _physics_process(delta):	
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
		if !crouch:
			$Sprite.play("walk")
		$Sprite.playing = true
		if crouch and left:
			ocl.rotation = deg2rad(90)
		left = false
	elif Input.is_action_pressed("ui_left"):
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		$Sprite.flip_h = true
		if !left:
			$Sprite/projectilePos.position *= Vector2(-1,1)
			if crouch:
				ocl.rotation = deg2rad(-90)
		if !crouch:
			$Sprite.play("walk")
		$Sprite.playing = true
		left = true
	else:
		$Sprite.frame = 0
		$Sprite.playing = false
		motion.x = 0
		
	if Input.is_action_just_pressed("ui_switch"):
		$Sprite.play("crouch")
		col.rotation = deg2rad(90)
		if left:
			ocl.rotation = deg2rad(-90)
		else:
			ocl.rotation = deg2rad(90)
		crouch = true
	elif Input.is_action_just_released("ui_switch"):
		position.y -= 32
		col.rotation = deg2rad(0)
		ocl.rotation = deg2rad(0)
		$Sprite.play("walk")
		crouch = false
		
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
	if Input.is_action_just_pressed("ui_page_down"):
		globs.damage(-1)
			
	motion = move_and_slide(motion, UP)
	pass
	
	if Input.is_action_just_pressed("ui_change"):
		swap()

func _on_ProjectileTimer_timeout():
	cooldown = false

func swap():
	globs.switch_character()
	var x = NEXT_CHAR.instance()
	get_parent().add_child(x)
	x.global_position = global_position
	get_parent().remove_child(self)