extends CanvasLayer

var SPEED = 1
const LIMIT = 400
const PATH = "res://assets/scenes/Menu.tscn"
onready var bg = $backdrop
var moved = 0

func _ready():
	set_process(true)
	
func _process(delta):
	var k = Vector2(SPEED, 0)
	if SPEED > 0:
		if moved < LIMIT:
			moved += SPEED
			bg.translate(k)
		else:
			SPEED *= -1
	else:
		if moved > -LIMIT:
			moved += SPEED
			bg.translate(k)
		else:
			SPEED *= -1


func _on_Start_pressed():
	#Change me later!
	get_tree().change_scene("res://office.tscn")


func _on_Load_pressed():
	globs.save(0)


func _on_Options_pressed():
	pass # replace with function body


func _on_Quit_pressed():
	get_tree().quit()
