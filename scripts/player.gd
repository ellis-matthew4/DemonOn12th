extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 20
const ACCELERATION = 50
const MAX_SPEED = 200
const JUMP_HEIGHT = 550
const LADDER_SPEED = 300
const FIREBOLT_SCENE = preload("res://assets/scenes/firebolt.tscn")
const RUNE_SCENE = preload("res://assets/scenes/rune.tscn")
const PAUSE = preload("res://assets/scenes/PauseMenu.tscn")

var motion = Vector2()
var jumping = false
var on_ladder = false
var left = true
var cooldown = false
var crouch = false
var damaged = false
var attacking = false

onready var tilemap = get_tree().current_scene.find_node("midground")
onready var dmgTimer = $dmgTimer

func _ready():
	add_to_group("playable_characters")
	set_process(true)
	
func _process(delta):
	if !cooldown:
		if Input.is_action_just_pressed("ui_attack"):
			if !crouch:
				attacking = true
				$Sprite.play("cast")
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
	if Input.is_action_just_pressed("ui_pause"):
		$PauseMenu.show()
		get_tree().paused = true

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
	
	if Input.is_action_pressed("ui_right") and !crouch:
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
		$Sprite.flip_h = true
		if left:
			$Sprite/projectilePos.position = Vector2(80,-20)
		if !attacking:
			$Sprite.play("walk")
		$Sprite.playing = true
		left = false
	elif Input.is_action_pressed("ui_left") and !crouch:
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		$Sprite.flip_h = false
		if !left:
			$Sprite/projectilePos.position = Vector2(-80,-20)
		if !attacking:
			$Sprite.play("walk")
		$Sprite.playing = true
		left = true
	else:
		if !attacking:
			$Sprite.play("idle1")
		if !damaged:
			motion.x = 0
		
	if is_on_floor():
		if Input.is_action_pressed("ui_up"):
			motion.y -= JUMP_HEIGHT
	if Input.is_action_just_released("ui_up"):
		if motion.y < 0:
			motion.y *= 0.5;
	
	if Input.is_action_pressed("ui_switch"):
		$Sprite.play("crouch")
	
	if Input.is_action_just_pressed("ui_switch"):
		$Collider.position.y -= 12
		crouch = true
	elif Input.is_action_just_released("ui_switch"):
		position.y -= 10
		$Collider.position.y += 12
		$Sprite.play("walk")
		crouch = false
		
	if Input.is_action_just_pressed("ui_page_down"):
		globs.damage(-1)
			
	motion = move_and_slide(motion, UP)
	pass
	
	if Input.is_action_just_pressed("ui_change"):
		globs.switch_character()

func _on_ProjectileTimer_timeout():
	cooldown = false

func rocketJump(area):
	if area.BOOST:
		motion.y = -JUMP_HEIGHT * 1.3

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

func _on_Sprite_animation_finished():
	if $Sprite.animation == "cast":
		attacking = false
