extends KinematicBody2D

const SPEED = 600
var left = false
var motion = Vector2()

func _ready():
	if len(get_tree().get_nodes_in_group("playable_characters")) > 0:
		var player = get_tree().get_nodes_in_group("playable_characters")[0]
		left = (player.global_position < global_position)
		if left:
			$Sprite.flip_h = true
		set_process(true)
	else:
		queue_free()
	
func _process(delta):
	motion = Vector2(SPEED, 0)
	if left:
		motion.x *= -1
	move_and_slide(motion)

func _on_hitbox_body_entered(body):
	if body.is_in_group("playable_characters"):
		body.damage(self, -1)
	queue_free()

func damage(body, amount):
	queue_free()

func _on_Timer_timeout():
	queue_free()
