extends Camera2D

onready var screen_size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
onready var player = get_node("player")
onready var last_player_pos = player.global_position

func _ready():
	var canvas_transform = get_viewport().canvas_transform
	canvas_transform[2] = last_player_pos - screen_size / 2
	get_viewport().canvas_transform = canvas_transform

func _on_player_move():
	var player_offset = last_player_pos - player.global_position
	last_player_pos = player.global_position
	
	var canvas_transform = get_viewport().canvas_transform
	canvas_transform[2] += player_offset
	get_viewport().canvas_transform = canvas_transform
