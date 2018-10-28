extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 20
const ACCELERATION = 50
const MAX_SPEED = 200
const JUMP_HEIGHT = 550
const LADDER_SPEED = 300
const ATK = preload("res://assets/scenes/attackArea.tscn")
var NEXT_CHAR

var motion = Vector2()
var jumping = false
var on_ladder = false
var left = false
var crouch = false
var attacking = false
var damaged = false

var combo = 0
var thrust = false
var friction = false

onready var col = get_node("Collider")
onready var ocl = get_node("Sprite/LightOccluder2D")
onready var tilemap = get_tree().current_scene.find_node("midground")
onready var dmgTimer = $dmgTimer

func _ready():
	add_to_group("playable_characters")
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
			attack()
	
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
		$atk.flip_h = false
		if left:
			$Sprite/swordPos.position = Vector2(25, 4)
		if !crouch and !attacking:
			$Sprite.play("walkRight")
		$Sprite.playing = true
		if crouch and left:
			ocl.rotation = deg2rad(90)
		left = false
	elif Input.is_action_pressed("ui_left"):
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		$Sprite.flip_h = true
		$atk.flip_h = true
		if !left:
			$Sprite/swordPos.position = Vector2(-25, 4)
			if crouch:
				ocl.rotation = deg2rad(-90)
		if !crouch and !attacking:
			$Sprite.play("walkLeft")
		$Sprite.playing = true
		left = true
	else:
		if !attacking:
			$Sprite.playing = false
		if !friction:
			if !damaged:
				motion.x = 0
			
	if is_on_floor():
		if Input.is_action_pressed("ui_up"):
			motion.y -= JUMP_HEIGHT
		if friction:
			motion.x = lerp(motion.x, 0, 0.2)
		$attackTimer.wait_time = 0.1
	else:
		$attackTimer.wait_time = 0.2
		
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
				
	if Input.is_action_just_pressed("ui_page_down"):
		globs.damage(-1)
		
	if Input.is_action_just_released("ui_up"):
		if motion.y < 0:
			motion.y *= 0.5;
		
	if thrust:
		if left:
			motion.x -= MAX_SPEED
		else:
			motion.x += MAX_SPEED
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
		$atk.visible = false
		$atk.playing = false
		$atk.frame = 0
		
func attack():
	attacking = true
	$atk.frame = 0
	$atk.visible = true
	var a = ATK.instance()
	a.damage = 2
	$Sprite/swordPos.add_child(a)
	
	if combo == 0:
		combo = 1
		$atk.play("swing")
		$comboTimer.stop(); $comboTimer.start()
	elif combo == 1:
		combo = 2
		$atk.play("uppercut")
		$comboTimer.stop(); $comboTimer.start()
	elif combo == 2:
		combo = 0
		$atk.play("thrust")
		friction = true
		thrust = true
		$attackTimer.start()
	$atk.playing = true

func _on_frictionTimer_timeout():
	friction = false
	thrust = false

func _on_comboTimer_timeout():
	combo = 0

func hitbox_entered(area):
	if area.has_method("ladder"):
		on_ladder = true

func hitbox_exited(area):
	on_ladder = false
	
func damage(body, amount):
	globs.damage(amount)
	if body.global_position.x - global_position.x > 0:
		motion = Vector2(-200, -200)
	else:
		motion = Vector2(200, -200)
	dmgTimer.start()
	damaged = true

func _on_dmgTimer_timeout():
	damaged = false