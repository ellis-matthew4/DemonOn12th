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
var left = true
var cooldown = false
var damaged = false
var can_jump = true
var temp = false

enum { IDLE, JUMP, WALK, CAST, LADDER, CROUCH }
var state = IDLE
var sub = IDLE

onready var tilemap = get_tree().current_scene.get_child(0).find_node("midground")
onready var dmgTimer = $dmgTimer

func _ready():
	add_to_group("playable_characters")
	set_process(true)
	
func _process(delta):
	if !cooldown:
		if Input.is_action_just_pressed("ui_attack"):
			if state != CROUCH:
				fireBall()
			else:
				var rn = RUNE_SCENE.instance()
				tilemap.add_child(rn)
				rn.global_position = $Sprite/projectilePos.global_position
	if Input.is_action_just_pressed("ui_pause"):
		$PauseMenu.show()
		get_tree().paused = true

func _physics_process(delta):
	if sub != LADDER:
		match state:
			IDLE: $Sprite.play("idle1")
			JUMP: if sub == IDLE:
				$Sprite.play("jump")
			WALK: $Sprite.play("walk")
			CAST: $Sprite.play("cast")
			CROUCH: $Sprite.play("crouch")
			LADDER: pass
			_: print("STATE FAILURE")
	else:
		state = IDLE
		
	if sub == LADDER:
		$Sprite.play("climb")
		if Input.is_action_pressed("ui_up"):
			$Sprite.playing = true
			motion.y = -LADDER_SPEED
		elif Input.is_action_pressed("ui_down"):
			$Sprite.playing = true
			motion.y = LADDER_SPEED
		else:
			$Sprite.playing = false
			motion.y = 0
	else:
		motion.y += GRAVITY
	
	if Input.is_action_pressed("ui_right") and state != CROUCH:
		state = WALK
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
		$Sprite.flip_h = true
		if left:
			$Sprite/projectilePos.position = Vector2(80,-20)
		left = false
	elif Input.is_action_pressed("ui_left") and state != CROUCH:
		state = WALK
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		$Sprite.flip_h = false
		if !left:
			$Sprite/projectilePos.position = Vector2(-80,-20)
		left = true
	else:
		if state != CROUCH and state != JUMP and state != CAST:
			state = IDLE
		if !damaged:
			motion.x = 0
		
	if can_jump:
		if Input.is_action_just_pressed("ui_up"):
			state = JUMP
			motion.y = -JUMP_HEIGHT
			can_jump = false
			temp = true
	if Input.is_action_just_released("ui_up"):
		if motion.y < 0:
			motion.y *= 0.5;
			
	if is_on_floor():
		can_jump = true
		temp = false
		if state == JUMP:
			state = IDLE
	else:
		if state != CAST:
			state = JUMP
		if !temp:
			temp = true
			var k = Timer.new()
			k.wait_time = 0.2
			k.connect("timeout", self, "stopJump", [k])
			add_child(k)
			k.start()
		
	if Input.is_action_just_pressed("ui_switch"):
		state = CROUCH
	elif Input.is_action_just_released("ui_switch"):
		state = IDLE
		
	if Input.is_action_just_pressed("ui_page_down"):
		globs.damage(-1)
			
	motion = move_and_slide(motion, UP)
	pass
	
	if Input.is_action_just_pressed("ui_change"):
		globs.switch_character()

func _on_ProjectileTimer_timeout():
	cooldown = false

func rocketJump(area):
	 if area.has_method("boost"):
			motion.y = -JUMP_HEIGHT * 1.3

func hitbox_entered(area):
	if area.has_method("ladder"):
		sub = LADDER

func hitbox_exited(area):
	state = IDLE
	if area.has_method("ladder"):
		sub = IDLE
	
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
	if state == CAST:
		state = IDLE

func stopJump(k):
	temp = false
	can_jump = false
	remove_child(k)
	
func fireBall():
	state = CAST
	var fb = FIREBOLT_SCENE.instance()
	fb.orient(left)
	tilemap.add_child(fb)
	fb.position = $Sprite/projectilePos.global_position
	cooldown = true
	$ProjectileTimer.start()
	