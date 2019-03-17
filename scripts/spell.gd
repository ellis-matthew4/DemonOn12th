extends Light2D

func activate():
	enabled = true
	$Particles2D.emitting = true
func deactivate():
	enabled = false
	$Particles2D.emitting = false
	get_node("../../midground/Doors/world_door2").queue_free()