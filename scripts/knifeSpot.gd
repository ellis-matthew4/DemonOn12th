extends Sprite

func _on_Timer_timeout():
	var k = load("res://assets/scenes/paperKnife.tscn").instance()
	k.global_position = global_position
	get_parent().add_child(k)
	queue_free()