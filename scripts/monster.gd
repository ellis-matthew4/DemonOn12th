extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 20
const ACCELERATION = 50
const MAX_SPEED = 300
const JUMP_HEIGHT = 600
const ATK = preload("res://assets/scenes/attackArea.tscn")

var motion = Vector2()
var left = false
var damaged = false
var can_jump = true
var temp = false

enum { IDLE, JUMP, WALK, ATTACK }
var state = IDLE

onready var col = get_node("Collider")
onready var tilemap = get_tree().current_scene.find_node("midground")
onready var dmgTimer = $dmgTimer
onready var manaBar = $healthBar/ProgressBar

func _ready():
	pass

func _physics_process(delta):
	manaBar.value = $Timer.time_left
	match state:
		IDLE: $Sprite.play("idle")
		JUMP: $Sprite.play("jump")
		WALK: $Sprite.play("walk")
		ATTACK: pass
		_: print("STATE FAILURE")

	if Input.is_action_just_pressed("ui_attack"):
		if left:
			motion.x -= MAX_SPEED
		else:
			motion.x += MAX_SPEED
		attack()

	if Input.is_action_just_pressed("ui_pause"):
		$PauseMenu.show()
		get_tree().paused = true

	motion.y += GRAVITY

	if Input.is_action_pressed("ui_right"):
		motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
		$Sprite.flip_h = true
		$Sprite/swordPos.position = Vector2(72, -26)
		if state != ATTACK and state != JUMP:
			state = WALK
		left = false
	elif Input.is_action_pressed("ui_left"):
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		$Sprite.flip_h = false
		$Sprite/swordPos.position = Vector2(-72, -26)
		if state != ATTACK and state != JUMP:
			state = WALK
		left = true
	else:
		if state != JUMP and state != ATTACK:
			state = IDLE
		if !damaged:
			motion.x = 0
			
	if Input.is_action_just_pressed("ui_switch"):
		globs.transform_harry()

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

	if is_on_floor():
		can_jump = true
		temp = false
		if state == JUMP:
			state = IDLE
	else:
		if state != ATTACK:
			state = JUMP
		if !temp:
			temp = true
			var k = Timer.new()
			k.wait_time = 0.2
			k.connect("timeout", self, "stopJump", [k])
			add_child(k)
			k.start()

	motion = move_and_slide(motion, UP)
	pass

func _on_animation_finished():
	if state == ATTACK:
		state = IDLE

func attack():
	state = ATTACK
	var a = ATK.instance()
	a.damage = 4
	$Sprite/swordPos.add_child(a)
	$Sprite.play("attack")
	
func hitbox_entered(area):
	pass

func hitbox_exited(area):
	pass

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

func stopJump(k):
	temp = false
	can_jump = false
	remove_child(k)

func _on_Timer_timeout():
	globs.transform_harry()
