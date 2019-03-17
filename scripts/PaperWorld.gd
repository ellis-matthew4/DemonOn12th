extends Node2D

onready var CharacterSlot = get_node("midground/Characters")
const positions = { "officeDoor" : Vector2(640,520) }
var player
const PATH = "res://assets/levels/PaperWorld.tscn"

var nodeSet = []

var wrathCount = 0
var soldierScene = preload("res://assets/scenes/paperSoldier.tscn")

signal Switch

func _ready():
	loadInstance()
	getNodeSet()
	globs.SukiGD.read("paperWorld.json")
	placeCharacter()
	$midground/Mirror3.global_position += Vector2(0,1000)
	
func serialize():
	var dict = {}
	for n in nodeSet:
		if get_node(n) == null:
			dict[n] = false
		else:
			dict[n] = true
	return dict
	
func loadInstance():
	if globs.dungeon1 == {}:
		return
	var i = globs.dungeon1
	for n in i:
		if not i[n]:
			get_node(n).queue_free()

func save():
	globs.dungeon1 = serialize()
	
func getNodeSet():
	for c in $midground/Environment.get_children():
		nodeSet.append(get_path_to(c))
	for c in $midground/Treasure.get_children():
		nodeSet.append(get_path_to(c))
	for c in $midground/NPCs.get_children():
		nodeSet.append(get_path_to(c))
	nodeSet.append(get_path_to(get_node("midground/Doors/Door3")))
	
func placeCharacter():
	var pos = globs.spawnPoint
	player = globs.get_character(globs.selected_character)
	if pos in positions.keys():
		CharacterSlot.global_position = positions[pos]
	else:
		CharacterSlot.global_position = pos
	CharacterSlot.add_child(player)
	
func read(script):
	globs.SukiGD.call(script)

func enableBG():
	for c in $ParallaxBackground.get_children():
		c.visible = true
func disableBG():
	for c in $ParallaxBackground.get_children():
		c.visible = false

func _on_Greed_interact(n):
	read("greedEncounter")
	yield(globs.SukiGD, "done")
	var k = globs.SukiGD.get("greed")
	var wall
	if k:
		wall = get_node("midground/Environment/DisappearingArea-Paper3")
	else:
		wall = get_node("midground/Environment/DisappearingArea-Paper4")
	n.queue_free()
	wall.destroy()

func _on_Lust_interact(n):
	read("lustEncounter")

func _on_Envy_interact(n):
	read("envyEncounter")
	yield(globs.SukiGD, "done")
	var k = globs.SukiGD.get("envy")
	var wall
	if k:
		wall = get_node("midground/Environment/DisappearingArea-Paper2")
	else:
		wall = get_node("midground/Environment/DisappearingArea-Paper")
	n.queue_free()
	wall.destroy()

func _on_Wrath_interact(n):
	read("wrathEncounter")
	yield(globs.SukiGD, "done")
	$midground/Environment/WrathTimer.start()
	$midground/NPCs/Wrath.disable()

func _on_WrathTimer_timeout():
	var p = $midground/NPCs/Wrath.global_position
	if wrathCount >= 10:
		$midground/Environment/WrathTimer.queue_free()
		$midground/NPCs/Wrath.queue_free()
		get_node("midground/Environment/WrathWall").destroy()
	else:
		wrathCount += 1
		var k = soldierScene.instance()
		$midground/Enemies.add_child(k)
		k.global_position = p

func _on_Pride_interact(n):
	read("prideEncounter")
	yield(globs.SukiGD, "done")
	$midground/Environment/PrideWallEnter.global_position.y = 224
	yield(get_tree().create_timer(1), "timeout")
	var b = load("res://assets/scenes/prideAmal.tscn").instance()
	$midground/Enemies.add_child(b)
	b.global_position = n.global_position
	n.queue_free()
	yield(b, "dead")
	$midground/Environment/PrideWallEnter.destroy()
	$midground/Environment/PrideWallExit.destroy()

func _on_Gluttony_interact(n):
	read("gluttonyEncounter")

func _on_boss_door_passage():
	yield(get_tree().create_timer(3), "timeout")
	$midground/BossRoom.spawnBoss()

func _on_Sloth_interact(n):
	read("slothEncounter")

func _on_world_door_Switch():
	save()
	globs.spawnPoint = "mirror"
	emit_signal("Switch")

func _on_final_door_Switch():
	globs.SUBSTATE = 3
	save()
	globs.spawnPoint = "frontDoor"
	emit_signal("Switch")
