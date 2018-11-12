extends Node

var hp = [7,7,7]

var selected_character = 0 #0:John, 1:Harry, 2:Charlotte
var char_unlocked = false
var STATE = 0 #Controls the dialogue system by major category
var SUBSTATE = 0 #Controls the specific dialogues
var inventory = {}
var money = 0
var dict = {}

var spawnPoint
var path

onready var johnScene = preload("res://assets/scenes/player_john.tscn")
onready var harryScene = preload("res://assets/scenes/player_harry.tscn")
#onready var charlotteScene = preload("res://assets/scenes/player_charlotte.tscn")
onready var monsterScene = preload("res://assets/scenes/harry_monster.tscn")

onready var cameraScene = preload("res://assets/scenes/DefaultCamera.tscn")
var cam

func _ready():
	cam = cameraScene.instance()

func unlock_charlotte():
	char_unlocked = true
		
func switch_character():
	var charSlot = get_tree().current_scene.get_child(0).find_node("Characters")
	var current = charSlot.get_child(0)
	current.remove_child(cam)
	if char_unlocked:
		if selected_character < 2:
			selected_character += 1
		else:
			selected_character = 0
	else:
		if selected_character == 0:
			selected_character = 1
		else:
			selected_character = 0
	var k = get_character(selected_character)
	var p = current.global_position
	k.add_child(cam)
	charSlot.remove_child(current)
	charSlot.add_child(k)
	k.global_position = p
	
func remove_character():
	get_tree().current_scene.get_child(0).find_node("Characters").get_child(0).remove_child(cam)
	
func transform_monster():
	var charSlot = get_tree().current_scene.get_child(0).find_node("Characters")
	var current = charSlot.get_child(0)
	current.remove_child(cam)
	var k = monsterScene.instance()
	var p = current.global_position
	k.add_child(cam)
	charSlot.remove_child(current)
	charSlot.add_child(k)
	k.global_position = p
	
func transform_harry():
	var charSlot = get_tree().current_scene.get_child(0).find_node("Characters")
	var current = charSlot.get_child(0)
	current.remove_child(cam)
	var k = get_character(selected_character)
	var p = current.global_position
	k.add_child(cam)
	charSlot.remove_child(current)
	charSlot.add_child(k)
	k.global_position = p
	
func get_character(i):
	var k
	match(i):
		0: k = johnScene.instance()
		1: k = harryScene.instance()
		#2: var k = charlScene.instance()
		_: print("Failed to assign character")
	k.add_child(cam)
	return k
	
func damage(amount):
	hp[selected_character] += amount
	
func save(pos):
	var save_dict = {
        "filename" : "res://saveData.sav",
		"scene" : get_tree().current_scene.get_child(0).PATH,
		"position" : var2str(pos),
		"john_hp" : hp[0],
		"harry_hp" : hp[1],
		"charl_hp" : hp[2],
		"charlotte" : char_unlocked,
		"state" : STATE,
		"substate" : SUBSTATE,
		"inventory" : inventory,
		"money" : money
	}
	var save = File.new()
	save.open(save_dict["filename"], File.WRITE)
	save.store_line(to_json(save_dict))
	save.close()
	
func load():
	var f = File.new()
	f.open("res://saveData.sav", File.READ)
	var text = f.get_as_text()
	dict = JSON.parse(text).result
	f.close()
	hp[0] = dict["john_hp"]
	hp[1] = dict["harry_hp"]
	hp[2] = dict["charl_hp"]
	STATE = dict["state"]
	SUBSTATE = dict["substate"]
	inventory = dict["inventory"]
	money = dict["money"]
	spawnPoint = str2var(dict["position"])
	path = dict["scene"]
	get_tree().current_scene.switch()