extends KinematicBody2D

const SPEED = 400
enum { FLOAT, SHOOT, FOLD, IDLE, TRAVERSE, WAIT }
var state = FLOAT
var sub = IDLE

var health = 10
var target = Vector2()
var motion = Vector2()
var foldCount = 2

var yRange = range(2452,2816)
var xRange = range(4864,5696)

onready var knifeScene = preload("res://assets/scenes/paperKnife.tscn")
onready var knifeSpotScene = preload("res://assets/scenes/knifeSpot.tscn")

signal dead

func _ready():
	globs.boss = true
	randomize()
	set_process(true)

#warning-ignore:unused_argument
func _process(delta):
	if health <= 0:
		globs.boss = false
		emit_signal("dead")
		queue_free()
	$HUD/ProgressBar.value = health
	match(state):
		FLOAT: Float()
		SHOOT: shoot()
		FOLD: fold()
		_: print("State failure in object Shikigami")

#warning-ignore:unused_argument
#warning-ignore:unused_argument
func damage(body, amount):
	health -= 1
	
func Float():
	$Shikigami.play("float")
	if sub == IDLE:
		target = get_parent().getPos()
		sub = TRAVERSE
	elif sub == TRAVERSE:
		if global_position.distance_to(target) > 16:
			var angle = global_position.angle_to_point(target)
			var direction = Vector2(cos(angle), sin(angle)) * -1
			motion = direction * Vector2(SPEED, SPEED)
#warning-ignore:return_value_discarded
			move_and_slide(motion)
		else:
			motion = Vector2(0,0)
#warning-ignore:return_value_discarded
			move_and_slide(motion)
			global_position = target
			sub = WAIT
	else:
		motion = Vector2(0,0)
#warning-ignore:return_value_discarded
		move_and_slide(motion)

func shoot():
	$Shikigami.play("shoot")

func fold():
	$Shikigami.play("fold")

func _on_stateClock_timeout():
	if state == FLOAT:
		if sub == WAIT:
			state = SHOOT
			sub = IDLE
			if foldCount == 2 and health == 6:
				state = FOLD
				foldCount = 1
			if foldCount == 1 and health == 1:
				state = FOLD
				foldCount = 0
			if state == FOLD:
				$foldClock.start()

func _on_foldClock_timeout():
	state = SHOOT
	visible = true

func _on_shootClock_timeout():
	if state == FOLD:
		throwKnife(true)
	
func _on_Shikigami_animation_finished():
	if state == SHOOT:
		throwKnife(false)
		state = FLOAT
	elif state == FOLD:
		visible = false
		pass
		
func throwKnife(rand):
	var p = global_position
	var k = knifeScene.instance()
	if rand:
		p = Vector2(xRange[randi()%len(xRange)], yRange[randi()%len(yRange)])
		k = knifeSpotScene.instance()
	k.global_position = p
	get_parent().add_child(k)