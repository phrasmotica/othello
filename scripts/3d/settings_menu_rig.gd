extends Node3D

@export
var game_ui: GameUI

@export
var animation: AnimationPlayer

@export
var settings_menu: SettingsMenu3D

func _ready() -> void:
	if game_ui:
		SignalHelper.persist(game_ui.toggled_settings, _handle_toggled_settings)

	if settings_menu:
		settings_menu.hide()

func _handle_toggled_settings() -> void:
	if settings_menu and animation:
		settings_menu.show()

		animation.play("show_settings_menu")
