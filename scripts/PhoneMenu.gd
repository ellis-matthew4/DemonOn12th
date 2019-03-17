extends Control

var app

signal resume
signal savegame
signal loadgame

func _ready():
	loadAppList()

func open_contacts():
	app = load("res://assets/scenes/App-Contacts.tscn").instance()
	add_child(app)
	
func open_storage():
	app = load("res://assets/scenes/App-Storage.tscn").instance()
	add_child(app)

func savegame():
	emit_signal("savegame")

func loadgame():
	emit_signal("loadgame")

func resume():
	emit_signal("resume")

func loadAppList():
	app = load("res://assets/scenes/AppList.tscn").instance()
	add_child(app)
	app.connect("contacts", self, "open_contacts")
	app.connect("loadgame", self, "loadgame")
	app.connect("savegame", self, "savegame")
	app.connect("resume", self, "resume")
	app.connect("storage", self, "open_storage")

func back():
	remove_child(app)
	loadAppList()

func _on_ToolButton_pressed():
	resume()
