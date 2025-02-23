class_name GameButtons extends VBoxContainer

@export
var game_logic: OthelloGameLogic

@export
var settings_menu: Node3D

@onready
var restart_button: Button = %RestartButton

@onready
var settings_button: Button = %SettingsButton

@onready
var main_menu_button: Button = %MainMenuButton

signal quit_to_main_menu

func _ready() -> void:
	if settings_menu:
		settings_menu.hide()

	restart_button.pressed.connect(_handle_restarted)
	settings_button.pressed.connect(_handle_settings)
	main_menu_button.pressed.connect(_handle_quit)

func _handle_restarted() -> void:
	if game_logic:
		game_logic.restart_game()

func _handle_settings() -> void:
	if settings_menu:
		settings_menu.show()

func _handle_quit() -> void:
	quit_to_main_menu.emit()
