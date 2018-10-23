extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 20
const ACCELERATION = 50
const MAX_SPEED = 200
const JUMP_HEIGHT = 550
const LADDER_SPEED = 300
const CHAR = "Harry"
var NEXT_CHAR

var motion = Vector2()
var jumping = false
var on_ladder = false
var left = false
var crouch = false
var attacking = false

onready var col = get_node("Collider")
onready var ocl = get_node("Sprite/LightOccluder2D")
onready var atk = get_node("Sprite/swordCast")
onready var tilemap = get_tree().current_scene.find_node("midground")

func _ready():
	if globs.char_unlocked:
		#NEXT_CHAR = preload("res://assets/scenes/player_charlotte.tscn")
		pass
	else:
		NEXT_CHAR = preload("res://assets/scenes/player_john.tscn")
	set_process(true)
	
func _process(delta):
	pass

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_attack"):
		if !crouch:
			attacking = true
			atk.enabled = true
			$Sprite/atk.visible = true
			$Sprite/atk.playing = true
			if atk.is_colliding():
				var obj = atk.get_collider()
			atk.enabled = false
	
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
		$Sprite/atk.flip_h = false
		if left:
			atk.cast_to *= Vector2(-1,0)
		if !crouch and !attacking:
			$Sprite.play("walkRight")
		$Sprite.playing = true
		if crouch and left:
			ocl.rotation = deg2rad(90)
		left = false
	elif Input.is_action_pressed("ui_left"):
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		$Sprite.flip_h = true
		$Sprite/atk.flip_h = true
		if !left:
			atk.cast_to *= Vector2(-1,0)
			if crouch:
				ocl.rotation = deg2rad(-90)
		if !crouch and !attacking:
			$Sprite.play("walkLeft")
		$Sprite.playing = true
		left = true
	else:
		if !attacking:
			$Sprite.playing = false
		motion.x = 0
		
	if Input.is_action_just_pressed("ui_switch"):
		col.rotation = deg2rad(90)
		if left:
			$Sprite.play("crouchLeft")
			ocl.rotation = deg2rad(-90)
		else:
			$Sprite.play("crouchRight")
			ocl.rotation = deg2rad(90)
		crouch = true
	elif Input.is_action_just_released("ui_switch"):
		position.y -= 32
		col.rotation = deg2rad(0)
		ocl.rotation = deg2rad(0)
		if left:
			$Sprite.play("walkLeft")
		else:
			$Sprite.play("walkRight")
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

func swap():
	globs.switch_character()
	var x = NEXT_CHAR.instance()
	get_parent().add_child(x)
	x.global_position = global_position
	get_parent().remove_child(self)

func _on_Sprite_animation_finished():
	if attacking:
		attacking = false
		$Sprite/atk.visible = false
		$Sprite/atk.playing = false
		$Sprite/atk.frame = 0
