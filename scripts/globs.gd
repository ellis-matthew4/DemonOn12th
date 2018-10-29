extends Node

var hp = [7,7,7]

var selected_character = 0 #0:John, 1:Harry, 2:Charlotte
var char_unlocked = false
var STATE = 0 #Controls the dialogue system by major category
var SUBSTATE = 0 #Controls the specific dialogues
var inventory = {}
var money = 0

func _ready():
	pass

func unlock_charlotte():
	char_unlocked = true
	
func switch_character():
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
	
func damage(amount):
	hp[selected_character] += amount
	
func save(pos):
	var save_dict = {
        "filename" : "res://saveData.sav",
		"scene" : get_tree().current_scene.PATH,
		"position" : pos,
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