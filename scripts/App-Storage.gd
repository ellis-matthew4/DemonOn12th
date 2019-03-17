extends Control

var itemScene = preload("res://assets/scenes/ItemDisplay.tscn")
var activePosition = 0
var active = false
var cNodes = []

func _ready():
	for j in range(0,3):
		if globs.inventory[j] > 0:
			for k in range(0, globs.inventory[j]):
				addItem(j)
	cNodes.append($Button)
	cNodes.append(get_parent().get_node("ToolButton"))
	set_process(true)

func addItem(id):
	var k = itemScene.instance()
	k.tex = load(globs.items[id]["texture"])
	k.buttonText = globs.items[id]["name"]
	k.buttonDesc = globs.items[id]["description"]
	k.index = id
	k.connect("interact", self, "button_interact")
	$ScrollContainer/VBoxContainer.add_child(k)
	cNodes.append(k)

func _process(delta):
	if Input.is_action_just_pressed("ui_up") and activePosition > 0:
		activePosition -= 1
		activate()
	elif Input.is_action_just_pressed("ui_down") and activePosition < (len(cNodes)-1):
		activePosition += 1
		activate()
	if active:
		get_viewport().warp_mouse(cNodes[activePosition].rect_global_position)
	if Input.is_action_just_pressed("ui_select"):
		cNodes[activePosition].emit_signal("pressed")

func _on_Back_pressed():
	get_parent().back()

func _on_Timer_timeout():
	active = false

func activate():
	active = true
	$Timer.start()
	
func button_interact(index):
	get_tree().paused = false
	globs.useItem(index)
	yield(get_tree().create_timer(0.05), "timeout")
	get_tree().paused = true
	get_parent().open_storage()
	queue_free()