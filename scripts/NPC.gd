extends Node2D

export(Texture) var sprite
signal interact(n)
var ready = false
var able = true
var p

func _ready():
	$Sprite.texture = sprite
	$Sprite.modulate = Color(1,1,1,1)
	set_process(true)
	
func _process(delta):
	if ready and able:
		if Input.is_action_just_pressed("ui_select"):
			able = false
			$Timer.start()
			if p.global_position.x > global_position.x:
				$Sprite.flip_h = true
			else:
				$Sprite.flip_h = false
			emit_signal("interact", self)

func _on_InteractArea_body_entered(body):
	if body.is_in_group("playable_characters"):
		p = body
		ready = true

func _on_InteractArea_body_exited(body):
	ready = false

func disable():
	$InteractArea.queue_free()

func _on_Timer_timeout():
	able = true
