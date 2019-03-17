extends KinematicBody2D

const SPEED = 500
var angle
var direction
var motion = Vector2()

func _ready():
	var player = get_tree().get_nodes_in_group("playable_characters")[0]
	angle = global_position.angle_to_point(player.global_position)
	rotation_degrees = rad2deg(angle)
	direction = Vector2(cos(angle), sin(angle)) * -1
	set_process(true)
	
func _process(delta):
	motion = direction * Vector2(SPEED, SPEED)
	move_and_slide(motion)

func _on_Timer_timeout():
	queue_free()

func _on_hitbox_body_entered(body):
	if body.is_in_group("playable_characters"):
		body.damage(self,-1)
	queue_free()

func damage(body, amount):
	queue_free()