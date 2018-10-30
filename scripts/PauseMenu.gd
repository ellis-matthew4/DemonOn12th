extends CanvasLayer

func _ready():
	pass
	
func show():
	$Control.visible = true
	$AnimationPlayer/gear.visible = true
	$AnimationPlayer/gear2.visible = true
	
func hide():
	$AnimationPlayer/gear.visible = false
	$AnimationPlayer/gear2.visible = false
	$Control.visible = false

func _on_resume_pressed():
	$Control.visible = false
	get_tree().paused = false
	hide()


func _on_options_pressed():
	pass # replace with function body


func _on_quit_pressed():
	get_tree().change_scene("res://assets/scenes/Menu.tscn")


func _on_save_pressed():
	var pos = get_tree().current_scene.find_node("Characters").get_child(0).position
	globs.save(pos)
