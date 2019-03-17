extends GridContainer

signal contacts
signal savegame
signal loadgame
signal resume
signal storage

var activePosition = Vector2(0,0)
var active = false

onready var buttons = [
[ $App1/Button, $App2/Button, $App3/Button, $App4/Button],
[ $App5/Button, $App6/Button, $App7/Button, $App8/Button],
[ $App9/Button, $App10/Button, $App11/Button, $App12/Button],
[get_parent().get_node("ToolButton")]]

func _ready():	
	set_process(true)
	
func _process(delta):
	if Input.is_action_just_pressed("ui_up") and activePosition.y > 0:
		activePosition.y -= 1
		activate()
	elif Input.is_action_just_pressed("ui_down") and activePosition.y < 3:
		activePosition.y += 1
		activate()
	elif Input.is_action_just_pressed("ui_left") and activePosition.x > 0:
		activePosition.x -= 1
		activate()
	elif Input.is_action_just_pressed("ui_right") and activePosition.x < 3:
		activePosition.x += 1
		activate()
	if activePosition.y == 3:
		activePosition.x = 0
	if active:
		get_viewport().warp_mouse(buttons[activePosition.y][activePosition.x].rect_global_position)
	if Input.is_action_just_pressed("ui_select"):
		buttons[activePosition.y][activePosition.x].emit_signal("pressed")
		
func activate():
	active = true
	$Timer.start()
	
func _on_save_pressed():
	emit_signal("savegame")

func _on_load_pressed():
	emit_signal("loadgame")

func _on_ToolButton_pressed():
	emit_signal("resume")

func _on_Timer_timeout():
	active = false

func _on_contacts_pressed():
	emit_signal("contacts")
	queue_free()

func _on_Storage_pressed():
	emit_signal("storage")
	queue_free()
