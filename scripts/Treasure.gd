extends KinematicBody2D

const SPEED = 300
var motion = Vector2()
var direction = Vector2()
var angle

var player

func _ready():
	$AnimationPlayer.play("float")

func _process(delta):
	if player != null:
		angle = global_position.angle_to_point(player.global_position)
		direction = Vector2(cos(angle), sin(angle)) * -1
		$AnimationPlayer.stop()
		motion = direction * Vector2(SPEED, SPEED)
		move_and_slide(motion)
		if global_position.distance_to(player.global_position) < 16:
			globs.addMoney(100)
			queue_free()

func _on_hitbox_body_entered(body):
	if body.is_in_group("playable_characters"):
		player = get_tree().get_nodes_in_group("playable_characters")[0]
		set_process(true)

func _on_AnimationPlayer_animation_finished(anim_name):
	$AnimationPlayer.play("float")
