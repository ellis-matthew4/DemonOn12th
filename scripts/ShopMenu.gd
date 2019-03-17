extends CanvasLayer

const prices = [ 200, 500, 1000 ]
var index = 0
var able = true

func _ready():
	get_tree().call_group("playable_characters", "hideGUI") #My games' command to hide the HUD
	get_tree().paused = true
	set_process(true)
	
func _process(delta):
	var t = globs.items[index]["description"] + " This item costs $" + str(prices[index]) + "."
	if globs.money < prices[index]:
		t += "\n\nYou can't afford this."
		able = false
	else:
		able = true
	var c = globs.inventory[index]
	t += "\nYou have " + str(c) + " of these."
	$Container/Label.text = t
	$Container2/Label.text = "Money: $" + str(globs.money) + ".00" 

func _on_Buy_pressed():
	if able:
		globs.money -= prices[index]
		globs.addItem(index)

func _on_Sell_pressed():
	if globs.inventory[index] > 0:
		globs.inventory[index] -= 1
		globs.money += prices[index]/2

func _on_Exit_pressed():
	get_tree().paused = false
	get_tree().call_group("playable_characters", "showGUI") #My games' command to hide the HUD
	queue_free()

func _on_DisplayPanel_interact(i):
	index = i
	