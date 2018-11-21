extends CanvasLayer

onready var projectRes = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
onready var charNodes = get_node("Characters")
onready var textBox = get_node("TextBox/TextControl/Dialogue")
onready var nameBox = get_node("TextBox/TextControl/Name")

var constants
var positions = {}
var characters = {}
var dialogue = []
var current = 0
var active = false
var click = false
var wait = true

func _ready():
	get_tree().root.connect("size_changed", self, "reloadRes")
	loadConstants("constants.json")
	set_process(true)
	
func _process(delta):
	if active:
		get_tree().call_group("playable_characters", "hideGUI")
		get_tree().paused = true
		get_node("TextBox").visible = true
		if Input.is_action_just_pressed("ui_select"):
			if current < len(dialogue):
				var statement = dialogue[current]
				if statement["action"] == "show":
					Show(statement)
					wait = true
				elif statement["action"] == "hide":
					Hide(statement)
					wait = true
				elif statement["action"] == "dialogue":
					dialogue(statement)
				current += 1
			else:
				hideAll()
				current = 0
				active = false
				wait = true
		else:
			if wait:
				if current < len(dialogue):
					var statement = dialogue[current]
					if statement["action"] == "show":
						Show(statement)
						current += 1
					elif statement["action"] == "hide":
						Hide(statement)
						current += 1
					elif statement["action"] == "dialogue":
						dialogue(statement)
						current += 1
						wait = false
	else:
		get_tree().call_group("playable_characters", "showGUI")
		get_tree().paused = false
	
func loadConstants(filename):
	var file = File.new()
	file.open("res://SukiGD/dialogue/" + filename, File.READ)
	var data = file.get_as_text()
	file.close()
	data = JSON.parse(data)
	if data.error != OK:
		print("FAILED TO LOAD FILE " + filename)
		return
	constants = data.result
	for p in constants["Positions"]:
		var pos = Vector2()
		pos.x = float(constants["Positions"][p]["x"])
		pos.y = float(constants["Positions"][p]["y"])
		positions[p] = pos * projectRes
	var temp = constants["Characters"]
	for c in temp:
		characters[c] = temp[c]
		characters[c]["path"] = characters[c]["path"].replace('"',"")
	
func read(filename):
	var file = File.new()
	file.open("res://SukiGD/dialogue/" + filename, File.READ)
	var data = file.get_as_text()
	file.close()
	data = JSON.parse(data)
	if data.error != OK:
		print("FAILED TO READ FILE " + filename)
		return
	dialogue = data.result["dialogue"]
	active = true
			
func Show(s): # 
	var c = charNodes.get_node(characters[s["char"]]["path"])
	c.global_position = positions[s["pos"]]
	c.frame = characters[s["char"]][s["emote"]]
	c.visible = true
	
func Hide(s):
	var c = charNodes.get_node(characters[s["char"]]["path"])
	c.global_position = Vector2(0,0)
	c.visible = false
func hideAll():
	get_node("TextBox").visible = false
	get_node("TextBox/TextControl/Dialogue").text = ""
	get_node("TextBox/TextControl/Name").text = ""
	for c in charNodes.get_children():
		c.global_position = Vector2(0,0)
		c.visible = false
		
func dialogue(s):
	if s.has("emote"):
		var c = charNodes.get_node(characters[s["char"]]["path"])
		c.frame = characters[s["char"]][s["emote"]]
	textBox.text = s["String"]
	nameBox.text = s["char"].capitalize()