extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 20
const ACCELERATION = 65
const MAX_SPEED = 300
const JUMP_HEIGHT = 550
const LADDER_SPEED = 300
const ATK = preload("res://assets/scenes/attackArea.tscn")
const PAUSE = preload("res://assets/scenes/PauseMenu.tscn")

var motion = Vector2()
var left = true
var damaged = false
var can_jump = true
var temp = false

var combo = 0
var thrust = false
var friction = true

enum { IDLE, JUMP, WALK, ATTACK, LADDER, CROUCH, FOLD }
var state = IDLE
var sub = IDLE

onready var col = get_node("Collider")
onready var tilemap = get_tree().current_scene.find_node("midground")
onready var dmgTimer = $dmgTimer

func _ready():
	set_process(true)
	
func _process(delta):
	pass

func _physics_process(delta):
	if sub != LADDER and sub != FOLD:
		match state:
			IDLE: $Sprite.play("idle")
			JUMP: $Sprite.play("jump")
			WALK: $Sprite.play("walk")
			ATTACK: pass
			LADDER: pass
			FOLD: $Sprite.play("fold")
			CROUCH: $Sprite.play("crouch")
			_: print("STATE FAILURE")
	else:
		state = IDLE
	
	if Input.is_action_just_pressed("ui_attack"):
		if state != CROUCH:
			attack()
		else:
			sub = FOLD
	
	if Input.is_action_just_pressed("ui_pause"):
		add_child(PAUSE.instance())
		
	if sub == FOLD:
		$Sprite.play("fold")
	
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
	
	if left:
		$Sprite.flip_h = false
		$Sprite/swordPos.position = Vector2(-245, -10)
	else:
		$Sprite.flip_h = true
		$Sprite/swordPos.position = Vector2(245, -10)
	
	if Input.is_action_pressed("ui_right") and state != CROUCH:
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
		if state != CROUCH and state != ATTACK and state != JUMP:
			state = WALK
		left = false
	elif Input.is_action_pressed("ui_left") and state != CROUCH:
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		if state != CROUCH and state != ATTACK and state != JUMP:
			state = WALK
		left = true
	else:
		if state != CROUCH and state != JUMP and state != ATTACK:
			state = IDLE
		if !friction:
			if !damaged:
				motion.x = 0
		else:
			motion.x = lerp(motion.x, 0, 0.3)
					
	if Input.is_action_just_pressed("ui_switch"):
		state = CROUCH
	elif Input.is_action_just_released("ui_switch"):
		state = IDLE
				
	if Input.is_action_just_pressed("ui_page_down"):
		globs.damage(-1)
		
	if can_jump:
		if Input.is_action_just_pressed("ui_up"):
			state = JUMP
			can_jump = false
			temp = true
			motion.y = -JUMP_HEIGHT
	if Input.is_action_just_released("ui_up"):
		if motion.y < 0:
			motion.y *= 0.5;
		if friction:
			motion.x = lerp(motion.x, 0, 0.05)
			
	if is_on_floor():
		can_jump = true
		temp = false
		if state == JUMP:
			state = IDLE
		$attackTimer.wait_time = 0.1
	else:
		if state != ATTACK:
			state = JUMP
		$attackTimer.wait_time = 0.2
		if !temp:
			temp = true
			var k = Timer.new()
			k.wait_time = 0.2
			k.connect("timeout", self, "stopJump", [k])
			add_child(k)
			k.start()
		if friction:
			motion.x = lerp(motion.x, 0, 0.2)
			
	if thrust:
		if left:
			motion.x -= MAX_SPEED
		else:
			motion.x += MAX_SPEED
			
	if $wallDetector.get_overlapping_bodies().size() > 0:
		position.y -= 10
					
	motion = move_and_slide(motion, UP)
	pass
	
	if Input.is_action_just_pressed("ui_change"):
		globs.switch_character()

func _on_animation_finished():
	if state == ATTACK:
		state = IDLE
	if sub == FOLD:
		globs.transform_plane()
		
func attack():
	state = ATTACK
	var a = ATK.instance()
	a.damage = 2
	$Sprite/swordPos.add_child(a)
	$Sprite.play("attack")
	thrust = true
	$attackTimer.start()

func _on_frictionTimer_timeout():
	thrust = false

func _on_comboTimer_timeout():
	combo = 0

func hitbox_entered(area):
	if area.has_method("ladder"):
		sub = LADDER

func hitbox_exited(area):
	sub = IDLE
	
func damage(body, amount):
	globs.screenShake()
	globs.damage(amount)
	if body.global_position.x - global_position.x > 0:
		motion = Vector2(-200, -200)
	else:
		motion = Vector2(200, -200)
	dmgTimer.start()
	damaged = true

func _on_dmgTimer_timeout():
	damaged = false
	
func stopJump(k):
	temp = false
	can_jump = false
	remove_child(k)
	
func hideGUI():
	for c in $healthBar.get_children():
		c.visible = false
func showGUI():
	for c in $healthBar.get_children():
		c.visible = true