class_name GameButtons extends VBoxContainer

@onready
var restart_button: Button = %RestartButton

@onready
var settings_button: Button = %SettingsButton

@onready
var main_menu_button: Button = %MainMenuButton

signal restarted
signal toggle_settings
signal quit_to_main_menu

func _ready() -> void:
	SignalHelper.chain(restart_button.pressed, restarted)
	SignalHelper.chain(settings_button.pressed, toggle_settings)
	SignalHelper.chain(main_menu_button.pressed, quit_to_main_menu)
