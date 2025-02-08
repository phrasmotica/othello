@tool
class_name BoardCell extends Node2D

enum CounterPresence { BLACK, WHITE, NONE }
enum CounterType { BLACK, WHITE }

@export
var counter_presence := CounterPresence.NONE:
	set(value):
		if counter_presence != value:
			counter_presence = value
			counter_changed.emit(counter_presence)

			_refresh()

@export
var next_colour := CounterType.BLACK:
	set(value):
		if next_colour != value:
			next_colour = value

			_refresh()

@onready
var counter: Counter = %Counter

@onready
var counter_preview: Counter = %CounterPreview

@onready
var mouse_area_button: Button = %MouseAreaButton

signal counter_changed(presence: CounterPresence)

func _ready() -> void:
	if not Engine.is_editor_hint():
		mouse_area_button.mouse_entered.connect(_handle_mouse_entered)
		mouse_area_button.mouse_exited.connect(_handle_mouse_exited)
		mouse_area_button.pressed.connect(_handle_pressed)

	_handle_mouse_exited()
	_refresh()

func _refresh() -> void:
	var has_counter := counter_presence != CounterPresence.NONE

	if counter:
		counter.visible = has_counter
		counter.is_white = counter_presence == CounterPresence.WHITE

	if counter_preview:
		counter_preview.is_white = next_colour == CounterType.WHITE

	if mouse_area_button:
		mouse_area_button.disabled = has_counter

		if has_counter:
			mouse_area_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
		else:
			mouse_area_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _handle_mouse_entered() -> void:
	if counter_presence != CounterPresence.NONE:
		return

	counter_preview.show()

func _handle_mouse_exited() -> void:
	counter_preview.hide()

func _handle_pressed() -> void:
	if counter_presence != CounterPresence.NONE:
		return

	counter_presence = next_colour as CounterPresence

	counter_preview.hide()
