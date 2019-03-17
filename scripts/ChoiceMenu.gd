extends CanvasLayer

export var Choice_1 = ""
export var Choice_2 = ""

signal chosen(choice)

func _ready():
	pass
	
func interact():
	$VBoxContainer.visible = true
	get_tree().paused = true

func _on_Button1_pressed():
	get_tree().paused = false
	emit_signal("chosen", 0)
	queue_free()
	
func _on_Button2_pressed():
	get_tree().paused = false
	emit_signal("chosen", 1)
	queue_free()