extends Node2D

export var damage = 0

func _ready():
	$Timer.start()
		
func body_entered(body):
	if body.has_method("damage"):
		body.damage(self, damage)

func _on_Timer_timeout():
	queue_free()
