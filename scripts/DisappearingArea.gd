extends Sprite

onready var shape = $StaticBody2D/CollisionShape2D.shape

func _ready():
	$StaticBody2D/CollisionShape2D.shape = $StaticBody2D/CollisionShape2D.shape.duplicate(true)
	material = material.duplicate(true)
	$StaticBody2D/CollisionShape2D.shape.extents = Vector2(region_rect.size.x/2, region_rect.size.y/2)

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()

func destroy():
	$AnimationPlayer.play("burn")
	$StaticBody2D.queue_free()