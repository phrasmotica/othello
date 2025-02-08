@tool
class_name BoardCell extends Node2D

@onready
var counter: Node2D = %Counter

@onready
var counter_preview: Node2D = %CounterPreview

@onready
var mouse_area_button: Button = %MouseAreaButton

var _is_placed := false

func _ready() -> void:
	if not Engine.is_editor_hint():
		mouse_area_button.mouse_entered.connect(_handle_mouse_entered)
		mouse_area_button.mouse_exited.connect(_handle_mouse_exited)
		mouse_area_button.pressed.connect(_handle_pressed)

	_handle_mouse_exited()

func _handle_mouse_entered() -> void:
	if _is_placed:
		return

	counter_preview.show()

func _handle_mouse_exited() -> void:
	counter_preview.hide()

func _handle_pressed() -> void:
	if _is_placed:
		return

	_is_placed = true

	counter_preview.hide()
	counter.show()
