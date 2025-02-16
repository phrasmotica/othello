class_name MainMenuUI extends MarginContainer

@onready
var buttons: MainMenuButtons = %MainMenuButtons

signal started
signal quit

func _ready() -> void:
	if buttons:
		buttons.started.connect(started.emit)
		buttons.quit.connect(quit.emit)
