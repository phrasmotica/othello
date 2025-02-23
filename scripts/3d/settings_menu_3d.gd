class_name SettingsMenu3D extends Node3D

@export
var board: Board3D

@export
var animator: AnimationPlayer

@onready
var settings_menu_ui: SettingsMenuUI = %SettingsMenuUI

var _is_busy := false

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
	_hide_menu()

func toggle_menu() -> void:
	if _is_busy:
		print("Settings menu is busy!")
		return

	if visible:
		_hide_menu()
	else:
		_show_menu()

func _show_menu() -> void:
	_is_busy = true

	show()

	if animator:
		SignalHelper.once(animator.animation_finished, _finish_show)
		animator.play("show_settings_menu")
	else:
		_finish_show()

func _hide_menu() -> void:
	_is_busy = true

	if animator:
		SignalHelper.once(animator.animation_finished, _finish_hide)
		animator.play_backwards("show_settings_menu")
	else:
		_finish_hide()

func _finish_show(_anim_name: StringName = "") -> void:
	print("SettingsMenu finishing show")

	_is_busy = false

func _finish_hide(_anim_name: StringName = "") -> void:
	print("SettingsMenu finishing hide")
	hide()

	_is_busy = false
