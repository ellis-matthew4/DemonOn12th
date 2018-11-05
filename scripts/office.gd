extends Node

onready var CharacterSlot = get_node("midground/Characters")
const start = Vector2(144,575)
var player
const PATH = "res://office.tscn"

func _ready():
	player = globs.get_character()
	CharacterSlot.global_position = start
	CharacterSlot.add_child(player)
	set_process(true)
	
func _process(delta):
	if Input.is_key_pressed(KEY_F):
		$MagicCircle/spell.activate()
	if Input.is_key_pressed(KEY_R):
		$MagicCircle/spell.deactivate()
