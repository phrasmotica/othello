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

func set_interactable(interactable: bool) -> void:
	var filter := Control.MOUSE_FILTER_STOP if interactable else Control.MOUSE_FILTER_IGNORE

	if start_game_button:
		start_game_button.mouse_filter = filter

	if quit_button:
		quit_button.mouse_filter = filter
