extends RigidBody2D

export var SPEED = -180
const DEATH = preload("res://assets/scenes/SlimeDeath.tscn")
var motion = Vector2(0,0)

onready var sprite = $AnimatedSprite
onready var ray = $RayCast2D
onready var spear = $Spear/CollisionShape2D

enum { IDLE, WALK, RUN }
var state = WALK

func _ready():
	$Timer.start()
	set_process(true)
	
func _process(delta):
	match(state):
		IDLE:
			sprite.play("idle")
			motion = Vector2(0,0)
		WALK:
			sprite.play("walk")
			motion = Vector2(SPEED * delta, 0)
		RUN:
			sprite.play("run")
			motion = Vector2(SPEED * 2 * delta, 0)
		
	if ray.is_colliding():
		ray.cast_to.x *= -1
		spear.rotation_degrees *= -1
		SPEED *= -1
		sprite.flip_h = !sprite.flip_h
		
	position += motion


func _on_Timer_timeout():
	$Timer.start()
	if state == WALK:
		state = IDLE
	elif state == IDLE:
		if detectPlayer():
				state = RUN
		else:
			state = WALK
	elif state == RUN:
		if detectPlayer():
			state = WALK
		else:
			if not detectPlayer():
				state = WALK
	else:
		print("STATE ERROR")
		
func detectPlayer():
	var p = get_tree().current_scene.find_node("Characters").get_child(0).global_position
	var m = global_position
	if abs(p.y-m.y) < 100:
		if SPEED < 0:
			if m.x > p.x and abs(m.x-p.x) <= 500:
				return true
		else:
			if m.x < p.x and abs(m.x-p.x) <= 500:
				return true
	return false

func _on_Spear_body_entered(body):
	if state == RUN:
		if body.is_in_group("playable_characters"):
			body.damage(self, -2)

func damage(obj, damage):
	queue_free()