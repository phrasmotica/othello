class_name SettingsMenuRig extends Node3D

@export
var input_handler: InputHandler

@export
var environment_manager: EnvironmentManager

@export
var board: Board3D

@export
var game_ui: GameUI

@onready
var settings_menu: SettingsMenu3D = %SettingsMenu3D

@onready
var animation: AnimationPlayer = %AnimationPlayer

var _is_busy := false

signal settings_menu_toggled(is_visible: bool)

func _ready() -> void:
	if input_handler:
		SignalHelper.persist(input_handler.toggled_settings, toggle_menu)

	if game_ui:
		SignalHelper.persist(game_ui.toggled_settings, toggle_menu)

	if settings_menu:
		SignalHelper.persist(settings_menu.preview_flips_toggled, _handle_preview_flips_toggled)
		SignalHelper.persist(settings_menu.auto_skip_toggled, _handle_auto_skip_toggled)
		SignalHelper.persist(settings_menu.environment_index_changed, _handle_environment_index_changed)
		SignalHelper.persist(settings_menu.close_button_pressed, _hide_menu)

		# hide the menu without animating it
		settings_menu.hide()

func toggle_menu() -> void:
	if _is_busy:
		print("Settings menu is busy!")
		return

	if settings_menu.visible:
		_hide_menu()
	else:
		_show_menu()

func _handle_environment_index_changed(index: int) -> void:
	if environment_manager:
		environment_manager.selected_index = index

func _handle_preview_flips_toggled(toggled_on: bool) -> void:
	if board:
		board.show_flip_previews = toggled_on

func _handle_auto_skip_toggled(toggled_on: bool) -> void:
	Globals.auto_skip = toggled_on

func _show_menu() -> void:
	_is_busy = true

	settings_menu.show()

	if animation:
		SignalHelper.once(animation.animation_finished, _finish_show)
		animation.play("show_settings_menu")
	else:
		_finish_show()

func _hide_menu() -> void:
	_is_busy = true

	if animation:
		SignalHelper.once(animation.animation_finished, _finish_hide)
		animation.play_backwards("show_settings_menu")
	else:
		_finish_hide()

func _finish_show(_anim_name: StringName = "") -> void:
	print("SettingsMenuRig finishing show")

	_is_busy = false

	settings_menu_toggled.emit(true)

func _finish_hide(_anim_name: StringName = "") -> void:
	print("SettingsMenuRig finishing hide")

	settings_menu.hide()

	_is_busy = false

	settings_menu_toggled.emit(false)
