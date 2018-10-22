extends Node

func _ready():
	set_process(true)
	
func _process(delta):
	if Input.is_key_pressed(KEY_F):
		$MagicCircle/spell.activate()
	if Input.is_key_pressed(KEY_R):
		$MagicCircle/spell.deactivate()
