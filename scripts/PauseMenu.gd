extends CanvasLayer

func _ready():
	get_tree().paused = true
	
func hide():
	get_tree().paused = false
	queue_free()

func _on_resume_pressed():
	$Control.visible = false
	hide()

func _on_options_pressed():
	pass # replace with function body

func _on_quit_pressed():
	get_tree().paused = false
	globs.remove_character()
	globs.path = "res://assets/scenes/Menu.tscn"
	get_tree().current_scene.switch()

func _on_save_pressed():
	if !globs.boss:
		var pos = get_tree().current_scene.get_child(0).find_node("Characters").get_child(0).global_position
		get_tree().current_scene.get_child(0).save()
		globs.save(pos)

func _on_load_pressed():
	globs.load()
