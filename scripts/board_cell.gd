@tool
class_name BoardCell extends Node2D

enum CounterType { NONE, BLACK, WHITE }

@export
var counter_type: CounterType:
	set(value):
		counter_type = value

		_refresh()

@onready
var counter: Counter = %Counter

@onready
var counter_preview: Node2D = %CounterPreview

@onready
var mouse_area_button: Button = %MouseAreaButton

func _ready() -> void:
	if not Engine.is_editor_hint():
		mouse_area_button.mouse_entered.connect(_handle_mouse_entered)
		mouse_area_button.mouse_exited.connect(_handle_mouse_exited)
		mouse_area_button.pressed.connect(_handle_pressed)

	_handle_mouse_exited()

func _refresh() -> void:
	counter.visible = counter_type != CounterType.NONE
	counter.is_white = counter_type == CounterType.WHITE

func _handle_mouse_entered() -> void:
	if counter_type != CounterType.NONE:
		return

	counter_preview.show()

func _handle_mouse_exited() -> void:
	counter_preview.hide()

func _handle_pressed() -> void:
	if counter_type != CounterType.NONE:
		return

	counter_type = CounterType.BLACK

	counter_preview.hide()
