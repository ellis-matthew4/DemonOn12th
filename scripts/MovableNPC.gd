extends KinematicBody2D

export(SpriteFrames) var Frames
signal interact(body)
var ready = false
var left = false
var SPEED = 200

enum { IDLE, WALK }
var state = IDLE

var queue = []
onready var initialposition = global_position

func _ready():
	$Sprite.frames = Frames
	$Sprite.modulate = Color(1,1,1,1)
	set_process(true)

func _process(delta):
	if left:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
	match(state):
		IDLE: $Sprite.play("idle")
		WALK: $Sprite.play("walk")
	if ready:
		if Input.is_action_just_pressed("ui_select"):
			emit_signal("interact", self)
	
	if queue.size() > 0:
		state = WALK
		move_towards(initialposition, queue[0], delta)
	else:
		state = IDLE
				
func move_towards(pos, point, delta):
	var v = (point-pos).normalized()
	if v.x > 0:
		left = true
	else:
		left = false
	v *= SPEED
	move_and_slide(v)
	if position.distance_squared_to(point) < 9:
		queue.remove(0)
		initialposition = global_position

func _on_InteractArea_body_entered(body):
	if body.is_in_group("playable_characters"):
		ready = true

func _on_InteractArea_body_exited(body):
	ready = false

func move_to(point):
	queue.append(point)
	
func move_relative(offset):
	if len(queue) > 0:
		move_to(Vector2(queue.back().x + offset.x, queue.back().y + offset.y))
	else:
		move_to(Vector2(global_position.x + offset.x, global_position.y + offset.y))