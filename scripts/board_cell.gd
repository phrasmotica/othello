@tool
class_name BoardCell extends Node2D

enum CounterPresence { BLACK, WHITE, NONE }
enum CounterType { BLACK, WHITE }

@export
var counter_presence := CounterPresence.NONE:
	set(value):
		if counter_presence != value:
			counter_presence = value

			_refresh()

@export
var next_colour := CounterType.BLACK:
	set(value):
		if next_colour != value:
			next_colour = value

			_refresh()

@export
var index: int = 0:
	set(value):
		if index != value:
			index = value

			_refresh()

@export
var cannot_place := false:
	set(value):
		if cannot_place != value:
			cannot_place = value

			_refresh()

@export
var debug_mode := false:
	set(value):
		if debug_mode != value:
			debug_mode = value

			_refresh()

@onready
var counter: Counter = %Counter

@onready
var counter_preview: Counter = %CounterPreview

@onready
var mouse_area_button: Button = %MouseAreaButton

@onready
var index_label: Label = %IndexLabel

## Signal to emit when a player places a counter in this cell.
signal counter_changed(presence: CounterPresence)

## Signal to emit when a cell's counter is flipped after a player has placed a
## counter elsewhere.
signal counter_flipped(presence: CounterPresence)

func _ready() -> void:
	if not Engine.is_editor_hint():
		mouse_area_button.mouse_entered.connect(_handle_mouse_entered)
		mouse_area_button.mouse_exited.connect(_handle_mouse_exited)
		mouse_area_button.pressed.connect(_handle_pressed)

		Globals.toggled_debug_mode.connect(_handle_toggled_debug_mode)

	_handle_mouse_exited()
	_refresh()

func flip_counter() -> void:
	if counter_presence == CounterPresence.NONE:
		return

	if counter_presence == CounterPresence.BLACK:
		counter_presence = CounterPresence.WHITE
		counter_flipped.emit(counter_presence)

	elif counter_presence == CounterPresence.WHITE:
		counter_presence = CounterPresence.BLACK
		counter_flipped.emit(counter_presence)

func _handle_toggled_debug_mode(is_debug: bool) -> void:
	debug_mode = is_debug

func _refresh() -> void:
	if debug_mode and cannot_place:
		modulate = Color.DIM_GRAY
	else:
		modulate = Color.WHITE

	if counter:
		counter.visible = counter_presence != CounterPresence.NONE
		counter.is_white = counter_presence == CounterPresence.WHITE

	if counter_preview:
		counter_preview.is_white = next_colour == CounterType.WHITE

	if mouse_area_button:
		if cannot_place:
			mouse_area_button.disabled = true
			mouse_area_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
		else:
			mouse_area_button.disabled = false
			mouse_area_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	if index_label:
		index_label.visible = debug_mode
		index_label.text = str(index)

func _handle_mouse_entered() -> void:
	if cannot_place:
		return

	counter_preview.show()

func _handle_mouse_exited() -> void:
	counter_preview.hide()

func _handle_pressed() -> void:
	if cannot_place:
		return

	place_counter()

func place_counter() -> void:
	counter_presence = next_colour as CounterPresence
	counter_changed.emit(counter_presence)

	counter_preview.hide()
