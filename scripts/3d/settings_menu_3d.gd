class_name SettingsMenu3D extends Node3D

@onready
var settings_menu_ui: SettingsMenuUI = %SettingsMenuUI

signal preview_flips_toggled(is_on: bool)
signal environment_index_changed(index: int)
signal close_button_pressed

func _ready() -> void:
	if settings_menu_ui:
		SignalHelper.chain(
			settings_menu_ui.preview_flips_check_box_toggled,
			preview_flips_toggled
		)

		SignalHelper.chain(
			settings_menu_ui.environment_cycler_selected_index_changed,
			environment_index_changed
		)

		SignalHelper.chain(
			settings_menu_ui.close_button_pressed,
			close_button_pressed
		)
