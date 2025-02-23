extends Node3D

@export
var board: Board3D

@onready
var settings_menu_ui: SettingsMenuUI = %SettingsMenuUI

func _ready() -> void:
	if settings_menu_ui:
		SignalHelper.persist(
			settings_menu_ui.preview_flips_check_box_toggled,
			_handle_preview_flips_toggled
		)

		SignalHelper.persist(
			settings_menu_ui.close_button_pressed,
			_handle_close_button_pressed
		)

func _handle_preview_flips_toggled(toggled_on: bool) -> void:
	if board:
		board.show_flip_previews = toggled_on

func _handle_close_button_pressed() -> void:
	hide()
