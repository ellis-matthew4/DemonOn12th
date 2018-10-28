extends Area2D

var timer
var damage = 2
const BOOST = true

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

func entered_hitbox(body):
	if body.has_method("damage"):
		body.damage(self, damage)
