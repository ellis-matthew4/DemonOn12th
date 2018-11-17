extends Control

onready var globs = get_node("/root/globs")

func _ready():
	$john.frame = globs.hp[0] #move to a signal when health changes
	set_process(true)
	
func _process(delta):
	if globs.char_unlocked and !$charlotte.visible:
		$charlotte.visible = true
	$john/bar.frame = globs.hp[0]
	$harry/bar.frame = globs.hp[1]
	$charlotte/bar.frame = globs.hp[2]
	$Label.text = str(Engine.get_frames_per_second())