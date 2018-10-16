extends Light2D

func activate():
	enabled = true
	$Particles2D.emitting = true
func deactivate():
	enabled = false
	$Particles2D.emitting = false