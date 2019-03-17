extends KinematicBody2D

const GRAVITY = 20
const ACCELERATION = 50
const MAX_SPEED = 200
const JUMP_HEIGHT = 550
const LADDER_SPEED = 300
const FIREBOLT_SCENE = preload("res://assets/scenes/firebolt.tscn")
const RUNE_SCENE = preload("res://assets/scenes/rune.tscn")
const PAUSE = preload("res://assets/scenes/PauseMenu.tscn")
const BURST = preload("res://assets/scenes/DamagelessExplosion.tscn")
const fade = preload("res://assets/shaders/TransitionFade.tscn")

var motion = Vector2()
var left = true
var cooldown = false
var damaged = false
var can_jump = true
var fallDelay = false
var canDoubleJump = true
var fallSpeed = 0

enum { IDLE, JUMP, WALK, CAST, LADDER, CROUCH, UP, DOWN, LEFT, RIGHT }
var state = IDLE
var sub = IDLE
var dir = IDLE

func _physics_process(delta):
	# Handler for game over
	if globs.hp[0] <= 0:
		globs.hp[0] = 7
		globs.path = "res://assets/scenes/GameOver.tscn"
		var f = fade.instance()
		globs.add_child(f)
		yield(f, "faded")
		get_tree().current_scene.switch()
	# Handler for pausing the game:
	if Input.is_action_just_pressed("ui_pause"):
		add_child(PAUSE.instance())
	
	# Switch to control direction state
	if Input.is_action_pressed("ui_right"):
		dir = RIGHT
		setDirection(false)
	elif Input.is_action_pressed("ui_left"):
		dir = LEFT
		setDirection(true)
	elif Input.is_action_pressed("ui_up"):
		dir = UP
	elif Input.is_action_pressed("ui_down"):
		dir = DOWN
	else:
		dir = IDLE
	
	# Animation controller
	if sub == IDLE:
		match state:
			IDLE: $Sprite.play("idle1")
			JUMP: if sub == IDLE:
				$Sprite.play("jump")
			WALK: $Sprite.play("walk")
			CROUCH: $Sprite.play("crouch")
			LADDER: pass
			_: print("STATE FAILURE")
	elif sub == LADDER:
		state = IDLE
		$Sprite.play("climb")
	elif sub == CAST:
		match state:
			IDLE:
				if dir == UP:
					$Sprite.play("cast_up")
				else:
					$Sprite.play("cast")
			JUMP: 
				if dir == DOWN:
					$Sprite.play("cast_jump_down")
				else:
					$Sprite.play("cast_jump")
			WALK: $Sprite.play("cast_walking")
			CROUCH: $Sprite.play("cast_crouching")
			LADDER: pass
			_: print("Unidentified state in player controller")
			
	# Handler for attacking
	if Input.is_action_just_pressed("ui_attack"):
		sub = CAST
		if state != CROUCH:
			attack()
		else:
			var rn = RUNE_SCENE.instance()
			get_parent().get_parent().add_child(rn)
			rn.global_position = $Sprite/projectilePos.global_position
			
	# laddering and gravity handler
	if sub == LADDER:
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
		
	# Crouch and walking handler
	if state != CROUCH:
		if dir == RIGHT:
			state = WALK
			motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
			left = false
		elif dir == LEFT:
			state = WALK
			motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
			left = true
		else:
			if !(state in [CROUCH, JUMP, CAST]):
				state = IDLE
			if !damaged:
				motion.x = 0
	else:
		motion.x = 0
				
	# jumping handler, including a dynamic height controller based on how long the key is pressed
	# For whatever reason, this jump code is called again when a double jump occurs. Investigate later.
	if can_jump and state != CROUCH:
		if Input.is_action_just_pressed("ui_up"):
			fallSpeed = 0
			state = JUMP
			motion.y = -JUMP_HEIGHT
			can_jump = false
			fallDelay = true
	if Input.is_action_just_released("ui_up"):
		if motion.y < 0:
			motion.y *= 0.5;
	
	# state logic for jumping, consider reworking
	if is_on_floor():
		can_jump = true
		fallDelay = false
		if state == JUMP:
			if fallSpeed > 600:
				globs.emit_signal("longFall")
				globs.screenShake()
			state = IDLE
			canDoubleJump = true
	else:
		if motion.y > 0:
			fallSpeed = motion.y
		if state != CAST:
			state = JUMP
		if !fallDelay:
			fallDelay = true
			get_node("JumpTimer").start()
		if Input.is_action_just_pressed("ui_up") and state == JUMP:
			if canDoubleJump:
				doubleJump()
			
	# state handler for crouching
	if Input.is_action_just_pressed("ui_switch"):
		state = CROUCH
	elif Input.is_action_just_released("ui_switch"):
		state = IDLE
	motion = move_and_slide(motion, Vector2(0,-1))

# Setter function for the left keyword, controls display of actor
func setDirection(isLeft):
	left = isLeft
	if isLeft:
		$Sprite.flip_h = false
		$Sprite/projectilePos.position = Vector2(-80,-20)
	else:
		$Sprite.flip_h = true
		$Sprite/projectilePos.position = Vector2(80,-20)

# If an explosion is detected in the boostbox, it'll launch the player upwards
func rocketJump(area):
	if area.has_method("boost"):
		globs.screenShake()
		motion.y = -JUMP_HEIGHT * 1.3

# Double jump handler
func doubleJump():
	var e = BURST.instance()
	e.global_position = global_position + Vector2(0,32)
	get_parent().get_parent().add_child(e)
	motion.y = -JUMP_HEIGHT
	canDoubleJump = false
		
# Ladder handlers
func hitbox_entered(area):
	if area.has_method("ladder"):
		sub = LADDER
func hitbox_exited(area):
	if area.has_method("ladder"):
		sub = IDLE

# Handler for taking damage
func damage(body, amount):
	globs.screenShake()
	globs.damage(amount)
	if body.global_position.x - global_position.x > 0:
		motion = Vector2(-200, -200)
	else:
		motion = Vector2(200, -200)
	damaged = true
	yield(get_tree().create_timer(0.3), "timeout")
	damaged = false

# Handler for the state machine to end casting animations
func _on_Sprite_animation_finished():
	if sub == CAST:
		sub = IDLE

# Function to reset the jump variables
func stopJump():
	fallDelay = false
	can_jump = false

# QOL Functions to hide and display the HUD
func hideGUI():
	for c in $healthBar.get_children():
		c.visible = false
func showGUI():
	for c in $healthBar.get_children():
		c.visible = true
		
func attack():
	var f = FIREBOLT_SCENE.instance()
	match state:
		IDLE:
			if dir == UP:
				f.orient(Vector2(0,-1))
			else:
				if left:
					f.orient(Vector2(-1,0))
				else:
					f.orient(Vector2(1,0))
		JUMP: 
			if dir == DOWN:
				f.orient(Vector2(0,1))
			else:
				if left:
					f.orient(Vector2(-1,0.6))
				else:
					f.orient(Vector2(1,0.6))
		WALK:
			if left:
				f.orient(Vector2(-1,0))
			else:
				f.orient(Vector2(1,0))
	f.global_position = $Sprite/projectilePos.global_position
	get_parent().get_parent().add_child(f)