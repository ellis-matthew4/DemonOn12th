extends Sprite

var obj = null

func _ready():
	$Area2D/CollisionShape2D.shape = $Area2D/CollisionShape2D.shape.duplicate(true)
	$Area2D/CollisionShape2D.shape.extents.x = region_rect.size.x/2

func _on_Area2D_body_entered(body):
	if body.has_method("damage"):
		body.damage(self, -5)
		$Timer.start()
		obj = body


func _on_Timer_timeout():
	if obj != null:
		obj.damage(self, -5)
	$Timer.start()


func _on_Area2D_body_exited(body):
	obj = null
	$Timer.stop()
