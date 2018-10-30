extends Control

onready var globs = get_node("/root/globs")

func _ready():
	$john.frame = globs.hp[0] #move to a signal when health changes
	set_process(true)
	
func _process(delta):
	$john/bar.frame = globs.hp[0]
	$harry/bar.frame = globs.hp[1]
	$Label.text = str(Engine.get_frames_per_second())