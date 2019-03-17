extends RigidBody2D

onready var sprite = $AnimatedSprite
onready var ray = $RayCast2D

enum { IDLE, DRAW, READY }
var state = IDLE

var arrow = preload("res://assets/scenes/arrow.tscn")

func _ready():
	$Timer.start()
	set_process(true)
	
func _process(delta):
	if len(get_tree().get_nodes_in_group("playable_characters")) > 0:
		var player = get_tree().get_nodes_in_group("playable_characters")[0]
		match(state):
			IDLE:
				sprite.play("idle")
			DRAW:
				sprite.play("draw")
			READY:
				sprite.play("draw")
				sprite.playing = false
				sprite.frame = 2
			
		if ray.is_colliding():
			if state != READY:
				state = DRAW
		else:
			state = IDLE
			
		if player.global_position.x > global_position.x:
			ray.cast_to = Vector2(500,0)
			sprite.flip_h = true
			$ArrowPosition.position = Vector2(8,11)
		else:
			ray.cast_to = Vector2(-500,0)
			sprite.flip_h = false
			$ArrowPosition.position = Vector2(-8,11)
	
func _on_Timer_timeout():
	if state == READY:
		shoot()
		state = DRAW
	$Timer.start()
	
func shoot():
	var a = arrow.instance()
	add_child(a)
	a.position = $ArrowPosition.position

func _on_AnimatedSprite_animation_finished():
	if state == DRAW:
		state = READY

func damage(body, amount):
	queue_free()