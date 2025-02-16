class_name MainMenuButtons extends VBoxContainer

@onready
var start_game_button: Button = %StartGameButton

@onready
var quit_button: Button = %QuitButton

signal started
signal quit

func _ready() -> void:
	start_game_button.pressed.connect(started.emit)
	quit_button.pressed.connect(quit.emit)
