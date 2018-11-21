extends Node

onready var CharacterSlot = get_node("midground/Characters")
const positions = { "start" : Vector2(144,575) }
var player
const PATH = "res://office.tscn"

onready var SukiGDPath = preload("res://SukiGD/Display.tscn")
var SukiGD

signal Switch

func _ready():
	placeCharacter()
	SukiGD = SukiGDPath.instance()
	add_child(SukiGD)
	set_process(true)
	
func _process(delta):
	if Input.is_key_pressed(KEY_F):
		dialogue()

func placeCharacter():
	var pos = globs.spawnPoint
	player = globs.get_character(globs.selected_character)
	if pos in positions.keys():
		CharacterSlot.remove_child(player)
		CharacterSlot.global_position = positions[pos]
	else:
		CharacterSlot.global_position = pos
	CharacterSlot.add_child(player)
	
func dialogue():
	SukiGD.read("script1.json")