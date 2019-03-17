extends Camera2D

var shake_amount = 2.0
var shaking = false

func _process(delta):
	if shaking:
	    set_offset(Vector2( \
	        rand_range(-1.0, 1.0) * shake_amount, \
	        rand_range(-1.0, 1.0) * shake_amount \
	    ))

func _on_Timer_timeout():
	shaking = false
	
func screenShake():
	shaking = true
	$Timer.start()