extends CanvasLayer

onready var projectRes = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
onready var charNodes = get_node("Characters")
onready var textBox = get_node("TextBox/TextControl/Dialogue")
onready var nameBox = get_node("TextBox/TextControl/Name")
var choice = preload("res://SukiGD/Choice.tscn")

var menuDict
var labels = {}
var variables = {}
var stack = []
var active = true
var skip = false
var auto = false
var working = false
var able = true

var tempSave

var line
var TEXT_SPEED = 10
var AUTO_SPEED = 2
var finishLine = false

var path_to_folder = "res://SukiGD/output/"
var currentScript

signal done
signal lineFinished

func _ready():
	set_process(true)
	
func _process(delta):
	if active:
		if len(stack) > 0: #Triggers upon calling or jumping
			if len(stack[0]) == 0:
				stack.pop_front()
			if Input.is_action_just_pressed("ui_select"):
				if line.has("String"):
					handleDialogue()
					yield(get_tree().create_timer(0.1), "timeout")
			elif skip:
				if len(stack) > 0:
					if stack.front().front()["action"] != "menu":
						nextLine()
				else:
					end()
		elif Input.is_action_just_pressed("ui_select") and working:
			end() # this is the problem
	if Input.is_key_pressed(KEY_CONTROL):
		skip = true
	else:
		skip = false
	if Input.is_key_pressed(KEY_F):
		print(get_tree().paused)
		
func handleDialogue():
	if textBox.text == line["String"] or $Centered.text == line["String"]:
		nextLine()
	else:
		finishLine = true
	
func read(filename):
	var file = File.new()
	file.open(path_to_folder + filename, File.READ)
	var data = file.get_as_text()
	file.close()
	data = JSON.parse(data)
	if data.error != OK:
		print("FAILED TO READ FILE " + filename)
		return
	labels = data.result["labels"]
	currentScript = filename

func nextLine():
	if len(stack) > 0:
		if len(stack.front()) > 0:
			line = stack[0].pop_front()
			statement()
		else:
			stack.pop_front()
			nextLine()
	else:
		if active:
			end()
		else:
			return

func statement():
	if line == null or line == {}:
		return
	if $Centered.text != "" or line["action"] != "centered":
		$Centered.text = ""
	match line["action"]:
		"show":
			Show(line)
		"hide":
			Hide(line)
		"dialogue":
			if !skip:
				dialogue(line)
			else:
				nameBox.text = line["char"].capitalize()
				textBox.text = line["String"]
		"adialogue":
			if !skip:
				adialogue(line)
			else:
				textBox.text = line["String"]
		"centered":
			if !skip:
				centered(1)
			else:
				$Centered.text = line["String"]
		"scene":
			Scene(line)
		"call":
			call(line["label"])
		"jump":
			jump(line["label"])
		"var":
			variable(line)
		"menu":
#			print("Menu detected")
			menuDict = line
			for k in line.keys():
				if k != "action":
					option(k)
			menu()
		"window":
			window(line)
		"play":
			play(line)
		"purchase":
			purchase(line)
		"wait":
			yield(get_tree().create_timer(int(line["args"][0])),"timeout")
		"return": nextLine()
		_:
			print(line)
			nextLine()
	
func call(label):
	if able:
		get_tree().call_group("playable_characters", "hideGUI") #My games' command to hide the HUD
		get_tree().paused = true #Remove this to disable pausing upon dialogue load
		get_node("TextBox").visible = true
		working = true
		push(label)
		nextLine()
	
func jump(label):
	if able:
		working = true
		stack = [labels[label].duplicate()]
		nextLine()
	
func push(label):
	var label2 = labels[label].duplicate()
	stack.push_front(label2)
	
func pushList(l):
	var l2 = l.duplicate()
	stack.push_front(l2)
	
func Show(s): # Show statement
	var c = charNodes.get_node(s["char"])
	c.global_position = $Positions.get_node(s["pos"]).global_position
	c.play(s["emote"])
	c.visible = true
	nextLine()
	
func Hide(s): # Hide statement
	var c = charNodes.get_node(s["char"])
	c.global_position = Vector2(0,0)
	c.visible = false
	nextLine()
func hideAll(): # Hides SukiGD
	get_node("TextBox").visible = false
	textBox.text = ""
	nameBox.text = ""
	for c in charNodes.get_children():
		c.global_position = Vector2(0,0)
		c.visible = false
	for sc in $Scenes.get_children():
		sc.visible = false
		
func dialogue(s): # Displays a line of dialogue
	if s.has("emote"):
		var c = charNodes.get_node(s["char"])
		c.play(s["emote"])
	$TextBox/Namebox.visible = true
	nameBox.visible = true
	nameBox.text = s["char"].capitalize()
	rollingDisplay(1)

func adialogue(s):
	$TextBox/Namebox.visible = false
	nameBox.visible = false
	rollingDisplay(1)
	
func centered(index):
	if !line.has("String") or skip:
		return
	if finishLine:
		textBox.text = line["String"]
		index = len(line["String"])
		finishLine = false
	if index <= len(line["String"]):
		$Centered.text = line["String"].substr(0,index)
		yield(get_tree().create_timer(pow(10,-TEXT_SPEED)), "timeout")
		centered(index + 1)
	else:
		emit_signal("lineFinished")
	
func rollingDisplay(index):
	if !line.has("String") or skip:
		return
	if finishLine:
		textBox.text = line["String"]
		index = len(line["String"])
		finishLine = false
	if index <= len(line["String"]):
		textBox.text = line["String"].substr(0,index)
		yield(get_tree().create_timer(pow(10,-TEXT_SPEED)), "timeout")
		rollingDisplay(index + 1)
	else:
		emit_signal("lineFinished")
	
func Scene(s): # Changes the backdrop to the current scene
	for sc in $Scenes.get_children():
		sc.visible = false
	get_node("Scenes/" + s["scene"]).visible = true
	nextLine()
		
func end():
	line = {}
	get_tree().paused = false
	hideAll()
	get_tree().call_group("playable_characters", "showGUI") #My games' command to show the HUD
	working = false
	emit_signal("done")
	able = false
	yield(get_tree().create_timer(0.5), "timeout")
	able = true
	
func variable(s):
	variables[s["name"]] = s["value"]
	nextLine()
	
func get(variable):
	return variables[variable]
	
func option(o):
	var c = choice.instance()
	$Menu.add_child(c)
	c.text = o
	c.connect("interact", self, "menu_interact", [o])
	
func menu():
	$Menu.visible = true
	$TextBox.visible = false
	active = false
	nextLine()
	
func menu_interact(o):
	pushList(menuDict[o])
	$Menu.visible = false
	$TextBox.visible = true
	active = true
	for c in $Menu.get_children():
		c.queue_free()
	menuDict = {}
	nextLine()
	
func window(s):
	if s["value"] == "hide":
		$TextBox.visible = false
	else:
		$TextBox.visible = true
	nextLine()
		
func play(s):
	$AnimationPlayer.play(s["anim"])
	nextLine()

func _on_root_lineFinished():
	if auto:
		yield(get_tree().create_timer(AUTO_SPEED), "timeout")
		nextLine()
		
func purchase(s):
	if int(s["args"][0]) <= globs.money:
		globs.addMoney(-1 * int(s["args"][0]))
		call(s["args"][1])
	else:
		call(s["args"][2])