extends Control

onready var globs = get_node("/root/globs")

func _ready():
	$john.frame = globs.hp[0] #move to a signal when health changes
	set_process(true)
	
func _process(delta):
	$john.frame = globs.hp[0]