extends Control

var contactScene = preload("res://assets/scenes/Contact.tscn")
var activePosition = 0
var active = false

onready var contacts = globs.phone["contacts"]
var cNodes = []

func _ready():
	var i = 0
	for c in contacts:
		var k = contactScene.instance()
		k.tex = load(c["texture"])
		k.buttonText = c["text"]
		k.index = i
		$ScrollContainer/VBoxContainer.add_child(k)
		cNodes.append(k)
		i += 1
	cNodes.append($Button)
	cNodes.append(get_parent().get_node("ToolButton"))
	set_process(true)
	
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