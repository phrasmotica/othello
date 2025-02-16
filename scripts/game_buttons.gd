class_name GameButtons extends VBoxContainer

@export
var game_logic: OthelloGameLogic

@onready
var restart_button: Button = %RestartButton

@onready
var quit_button: Button = %QuitButton

signal restarted

func _ready() -> void:
	restart_button.pressed.connect(_handle_restarted)
	quit_button.pressed.connect(_handle_quit)

func _handle_restarted() -> void:
	if game_logic:
		game_logic.restart_game()

	restarted.emit()

func _handle_quit() -> void:
	get_tree().quit()
