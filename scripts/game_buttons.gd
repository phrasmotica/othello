class_name GameButtons extends VBoxContainer

@export
var game_logic: OthelloGameLogic

@onready
var restart_button: Button = %RestartButton

@onready
var main_menu_button: Button = %MainMenuButton

signal restarted
signal quit_to_main_menu

func _ready() -> void:
	restart_button.pressed.connect(_handle_restarted)
	main_menu_button.pressed.connect(_handle_quit)

func _handle_restarted() -> void:
	if game_logic:
		game_logic.restart_game()

	restarted.emit()

func _handle_quit() -> void:
	quit_to_main_menu.emit()
