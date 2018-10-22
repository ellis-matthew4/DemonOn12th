extends Area2D

var timer

func _ready():
	timer = Timer.new()
	timer.connect("timeout", self, "tick")
	add_child(timer)
	timer.wait_time = 0.1
	timer.start()
	
func tick():
	if $Sprite.frame < 7:
		$Sprite.frame = $Sprite.frame + 1
	else:
		get_parent().remove_child(self)