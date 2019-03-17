extends StaticBody2D

func _ready():
	globs.connect("longFall", self, "checkPlayerPos")
	
func checkPlayerPos():
	var p = get_tree().get_nodes_in_group("playable_characters")[0].global_position
	var c = global_position
	if c.distance_to(p) < 100 and abs(p.x-c.x) < 32:
		queue_free()