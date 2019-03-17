extends StaticBody2D

export(Texture) var tex

func _ready():
	$Sprite.texture = tex
	$Particles2D.texture = tex

func _on_Area2D_body_entered(body):
	if body.is_in_group("attack"):
		$Sprite.visible = false
		$Particles2D.emitting = true
		yield(get_tree().create_timer(0.5), "timeout")
		queue_free()
