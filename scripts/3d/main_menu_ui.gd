class_name MainMenuUI extends MarginContainer

@export
var starting_animation: StringName

@export
var out_animation: StringName

@onready
var buttons: MainMenuButtons = %MainMenuButtons

@onready
var animation_player: AnimationPlayer = %AnimationPlayer

var _menu_ready := false

signal menu_ready
signal started
signal quit

func _ready() -> void:
	if buttons:
		buttons.started.connect(_handle_started)
		buttons.quit.connect(_handle_quit)

		buttons.set_interactable(false)

	if animation_player:
		animation_player.animation_finished.connect(_handle_animation_finished)
		animation_player.play(starting_animation)

func _handle_started() -> void:
	if _menu_ready:
		if buttons:
			buttons.set_interactable(false)

		animation_player.play(out_animation)

func _handle_quit() -> void:
	if _menu_ready:
		quit.emit()

func _handle_animation_finished(anim_name: StringName) -> void:
	if anim_name == starting_animation:
		_emit_menu_ready()

	if anim_name == out_animation:
		started.emit()

func _emit_menu_ready() -> void:
	if buttons:
		buttons.set_interactable(true)

	_menu_ready = true

	menu_ready.emit()
