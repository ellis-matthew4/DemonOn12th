extends ToolButton

export(Texture) var tex
export var buttonText = "John Smith"
export var index = 0

signal interact(index)

func _ready():
	randomize()
	$ColorRect.color = Color(get_color_bit(), get_color_bit(), get_color_bit(), 1.0)
	$Container/Label.text = buttonText
	$Container/TextureButton.texture_normal = tex

func _on_Contact_pressed():
	emit_signal("interact", index)

func get_color_bit():
	var x = randi() % 400
	x += 100
	x *= 0.001
	return x