extends KinematicBody2D

onready var proj = preload("res://assets/scenes/shadowBall.tscn")

enum { ATTACK, FLEE, CHARGE, PURSUE }
var state = PURSUE
const GRAVITY = 20
const SPEED = 400

var health = 7
var attack_ready = true
var can_flee = true
var player

var direction
var motion = Vector2()

signal dead

func _ready():
	set_process(true)
	
func _process(delta):
	if health > 0:
		player = get_tree().get_nodes_in_group("playable_characters")[0]
		direction = global_position.x - player.global_position.x
		direction /= direction
		
		match(state):
			ATTACK: attack()
			FLEE: flee()
			CHARGE: charge()
			PURSUE: pursue()
		if motion.x > 0:
			$WallDetector.cast_to = Vector2(35,0)
		else:
			$WallDetector.cast_to = Vector2(-35,0)
		motion.y += GRAVITY
		move_and_slide(motion)
	else:
		emit_signal("dead")
		queue_free()

func attack():
	motion.x = 0
	if attack_ready:
		$Sprite.play("attack")
		var k = proj.instance()
		get_parent().add_child(k)
		k.global_position = global_position
		attack_ready = false
		$Timer.start()
		
func flee():
	$WallDetector.enabled = true
	$Sprite.play("flee")
	if motion.x != 0:
		motion.x = direction * SPEED
	else:
		motion.x = SPEED
	
func charge():
	$WallDetector.enabled = true
	$Sprite.play("charge")
	motion.x = -direction * (2 * SPEED)

func pursue():
	$WallDetector.enabled = false
	$Sprite.play("pursue")
	motion.x = -direction * SPEED
		

func damage(body,amount):
	if body.global_position.x - global_position.x > 0:
		motion = Vector2(-200, -200)
	else:
		motion = Vector2(200, -200)
	health -= 1

func _on_Timer_timeout():
	attack_ready = true

func _on_FleeTimer_timeout():
	can_flee = true

func _on_SwitchTimer_timeout():
	var d = abs(global_position.x-player.global_position.x)
	if d < 400 and d > 200:
		state = ATTACK
	elif d > 400:
		state = PURSUE
	else:
		state = FLEE
	if $WallDetector.is_colliding():
		can_flee = false
		$FleeTimer.start()
		state = CHARGE

func _on_hitbox_body_entered(body):
	if body.is_in_group("playable_characters"):
		body.damage(self, -1)
