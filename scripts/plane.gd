extends KinematicBody2D

const MAX_SPEED = 500
const ACCEL = 10

var motion = Vector2()
var active = false

export var target = Vector2()
var start

var player
var playerParent

func _ready():
	start = global_position

func _physics_process(delta):
	if active:
		if global_position.distance_to(target) < 32:
			motion = Vector2(0,0)
			active = false
			var temp = target
			target = start
			start = temp
			playerParent.add_child(player)
			player.global_position = $Position2D.global_position
			remove_child(globs.cam)
			player.add_child(globs.cam)
		else:
			if global_position.x < target.x:
				$Sprite.flip_h = true
				if motion.x < MAX_SPEED:
					motion.x += ACCEL
			else:
				$Sprite.flip_h = false
				if motion.x < MAX_SPEED:
					motion.x -= ACCEL
	if Input.is_action_just_pressed("ui_select"):
		player = get_tree().get_nodes_in_group("playable_characters")[0]
		playerParent = player.get_parent()
		if player.global_position.distance_to(global_position) < 100:
			playerParent.remove_child(player)
			player.remove_child(globs.cam)
			add_child(globs.cam)
			active = true
	move_and_slide(motion)