extends KinematicBody2D

const SPEED = 500
var motion = Vector2()
var direction = Vector2()

func _ready():
	var player = get_tree().get_nodes_in_group("playable_characters")[0]
	var d = abs(global_position.x-player.global_position.x)
	direction = Vector2(-d/abs(d),0)
	set_process(true)
	
func _process(delta):
	motion = direction * Vector2(SPEED,SPEED)
	move_and_slide(motion)

func _on_hitbox_body_entered(body):
	if body.is_in_group("playable_characters"):
		body.damage(self, -1)
	queue_free()

func damage(body, k):
	pass

func _on_Timer_timeout():
	queue_free()
