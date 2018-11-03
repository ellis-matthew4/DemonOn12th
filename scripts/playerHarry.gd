extends KinematicBody2D

const UP = Vector2(0,-1)
const GRAVITY = 20
const ACCELERATION = 50
const MAX_SPEED = 200
const JUMP_HEIGHT = 550
const LADDER_SPEED = 300
const ATK = preload("res://assets/scenes/attackArea.tscn")

var motion = Vector2()
var jumping = false
var on_ladder = false
var left = false
var crouch = false
var attacking = false
var damaged = false
var can_jump = true
var temp = false

var combo = 0
var thrust = false
var friction = false

onready var col = get_node("Collider")
onready var tilemap = get_tree().current_scene.find_node("midground")
onready var dmgTimer = $dmgTimer

func _ready():
	set_process(true)
	
func _process(delta):
	pass

func _physics_process(delta):
	
	if Input.is_action_just_pressed("ui_attack"):
		if !crouch:
			attack()
	
	if Input.is_action_just_pressed("ui_pause"):
		$PauseMenu.show()
		get_tree().paused = true
	
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
		$Sprite/swordPos.position = Vector2(72, -26)
		if !crouch and !attacking:
			$Sprite.play("walk")
		left = false
	elif Input.is_action_pressed("ui_left") and !crouch:
		motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
		$Sprite.flip_h = false
		$Sprite/swordPos.position = Vector2(-72, -26)
		if !crouch and !attacking:
			$Sprite.play("walk")
		left = true
	else:
		if !attacking and !crouch:
			$Sprite.play("idle")
		if !friction:
			if !damaged:
				motion.x = 0
					
	if Input.is_action_just_pressed("ui_switch"):
		$Sprite.play("crouch")
		$Sprite/Particles2D.emitting = true
		crouch = true
	elif Input.is_action_just_released("ui_switch"):
		$Sprite/Particles2D.emitting = false
		crouch = false
				
	if Input.is_action_just_pressed("ui_page_down"):
		globs.damage(-1)
		
	if can_jump:
		if Input.is_action_just_pressed("ui_up"):
			motion.y -= JUMP_HEIGHT
		if friction:
			motion.x = lerp(motion.x, 0, 0.2)
	if Input.is_action_just_released("ui_up"):
		if motion.y < 0:
			motion.y *= 0.5;
			
	if is_on_floor():
		can_jump = true
		temp = false
		$attackTimer.wait_time = 0.1
	else:
		$attackTimer.wait_time = 0.2
		if !temp:
			temp = true
			var k = Timer.new()
			k.wait_time = 0.2
			k.connect("timeout", self, "stopJump", [k])
			add_child(k)
			k.start()
		
	if thrust:
		if left:
			motion.x -= MAX_SPEED
		else:
			motion.x += MAX_SPEED
	motion = move_and_slide(motion, UP)
	pass
	
	if Input.is_action_just_pressed("ui_change"):
		globs.switch_character()

func _on_animation_finished():
	if attacking:
		attacking = false
		
func attack():
	attacking = true
	var a = ATK.instance()
	a.damage = 2
	$Sprite/swordPos.add_child(a)
	
	if combo == 0:
		combo = 1
		$Sprite.play("swing")
		$comboTimer.stop(); $comboTimer.start()
	elif combo == 1:
		combo = 2
		$Sprite.play("uppercut")
		$comboTimer.stop(); $comboTimer.start()
	elif combo == 2:
		combo = 0
		$Sprite.play("thrust")
		friction = true
		thrust = true
		$attackTimer.start()

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
	
func stopJump(k):
	temp = false
	can_jump = false
	remove_child(k)