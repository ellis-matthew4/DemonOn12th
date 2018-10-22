extends Node

var hp = [7,7,7]

var selected_character = 0 #0:John, 1:Harry, 2:Charlotte
var char_unlocked = false

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