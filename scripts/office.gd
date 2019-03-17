extends Node

onready var CharacterSlot = get_node("midground/Characters")
const positions = { "start" : Vector2(144,575),
					"frontDoor" : Vector2(-320,540),
					"mirror" : Vector2(150,-260)
}
var player
const PATH = "res://office.tscn"
var fade = preload("res://assets/shaders/TransitionFade.tscn")

var ok = []

signal Switch

func _ready():
	placeCharacter()
	if globs.STATE == -1:
		globs.STATE = 0
		$MagicCircle/spell.deactivate()
	elif globs.STATE == 0:
		if globs.SUBSTATE == 1:
			yield(globs.SukiGD, "done")
			globs.SUBSTATE = 2
			ok.append($midground/NPCs/HarryMirror)
			$MagicCircle/spell.activate()
		elif globs.SUBSTATE == 2:
			ok.append($midground/NPCs/HarryMirror)
			$MagicCircle/spell.activate()
		elif globs.SUBSTATE == 3:
			yield(globs.SukiGD, "done")
			globs.STATE = 1
			globs.SUBSTATE = 0
			$MagicCircle/spell.deactivate()
		else:
			$MagicCircle/spell.deactivate()
	cullNPCs()
	
func cullNPCs():
	for c in $midground/NPCs.get_children():
		if !(c in ok):
			c.queue_free()

func save():
	pass

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

func _on_frontDoor_Switch():
	var f = fade.instance()
	globs.add_child(f)
	yield(f, "faded")
	globs.spawnPoint = "officeDoor"
	emit_signal("Switch")

func _on_Mirror_Switch():
	if globs.STATE == 0:
		if globs.SUBSTATE >= 2:
			var f = fade.instance()
			globs.add_child(f)
			yield(f, "faded")
			globs.spawnPoint = "officeDoor"
			emit_signal("Switch")

func _on_HarryMirror_interact(n):
	pass
