extends Node

onready var CharacterSlot = get_node("midground/Characters")
const start = Vector2(144,575)
const player = preload("res://assets/scenes/player_john.tscn")

func _ready():
	var p = player.instance()
	CharacterSlot.add_child(p)
	p.global_position = start
	set_process(true)
	
func _process(delta):
	if Input.is_key_pressed(KEY_F):
		$MagicCircle/spell.activate()
	if Input.is_key_pressed(KEY_R):
		$MagicCircle/spell.deactivate()
