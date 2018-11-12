extends Node

onready var CharacterSlot = get_node("midground/Characters")
const positions = { "start" : Vector2(144,575) }
var player
const PATH = "res://office.tscn"

signal Switch

func _ready():
	placeCharacter()
	set_process(true)
	
func _process(delta):
	if Input.is_key_pressed(KEY_F):
		$MagicCircle/spell.activate()
	if Input.is_key_pressed(KEY_R):
		$MagicCircle/spell.deactivate()

func placeCharacter():
	var pos = globs.spawnPoint
	player = globs.get_character(globs.selected_character)
	if pos in positions.keys():
		CharacterSlot.remove_child(player)
		CharacterSlot.global_position = positions[pos]
	else:
		CharacterSlot.global_position = pos
	CharacterSlot.add_child(player)