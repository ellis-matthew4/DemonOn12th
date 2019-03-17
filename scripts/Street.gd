extends Node2D

onready var CharacterSlot = get_node("midground/Characters")
const positions = { "officeDoor" : Vector2(340,996) }
var player
const PATH = "res://assets/levels/Street.tscn"

onready var SukiGDPath = preload("res://SukiGD/Display.tscn")
onready var nodeSet = []
var fade = preload("res://assets/shaders/TransitionFade.tscn")

signal Switch

func _ready():
	if globs.STATE == 0:
		globs.SukiGD.read("chapter1Major.json")
	getNodeSet()
	loadInstance()
	placeCharacter()
		
func save():
	globs.street = serialize()
	
func serialize():
	var dict = {}
	for n in nodeSet:
		if get_node(n) == null:
			dict[n] = false
		else:
			dict[n] = true
	return dict
	
func getNodeSet():
	for c in $midground/DiaCues.get_children():
		nodeSet.append(str(get_path_to(c)))
		
func loadInstance():
	if globs.street == {}:
		return
	var i = globs.street
	for n in i:
		if not i[n]:
			get_node(n).queue_free()

func placeCharacter():
	var pos = globs.spawnPoint
	player = globs.get_character(globs.selected_character)
	if pos in positions.keys():
		CharacterSlot.global_position = positions[pos]
	else:
		CharacterSlot.global_position = pos
	CharacterSlot.add_child(player)

func call(script):
	globs.SukiGD.call(script)

func _on_officeDoor_Switch():
	if globs.STATE == 0:
		if globs.SUBSTATE < 1:
			call("notYet")
		else:
			var f = fade.instance()
			globs.add_child(f)
			yield(f, "faded")
			switchToOffice()
	
func switchToOffice():
	save()
	globs.spawnPoint = "frontDoor"
	emit_signal("Switch")

func enableBG():
	for c in $ParallaxBackground.get_children():
		c.visible = true
func disableBG():
	for c in $ParallaxBackground.get_children():
		c.visible = false

func _on_NPC4_interact(body):
	call("npc2")
	yield(globs.SukiGD, "done")
	body.move_relative(Vector2(100,0))
	body.move_relative(Vector2(-100,0))

func _on_Shop_interact(n):
	call("shopkeep")
	yield(globs.SukiGD, "done")
	globs.openShop()

func _on_Chester_interact(n):
	if globs.STATE == 0:
		if globs.SUBSTATE <= 1:
			call("chesterMeet")
			yield(globs.SukiGD, "done")
			globs.SUBSTATE = 1
		elif globs.SUBSTATE == 2:
			call("chesterInteract")

func _on_NPC_interact(n):
	call("npc1")

func _on_DialogueCue_cue():
	call("towardShop")

func _on_DialogueCue2_cue():
	call("goSeeChester")
