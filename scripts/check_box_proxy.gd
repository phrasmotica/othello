extends Node

@export
var check_box: CheckBox

@export
var proxy: Control

var _mouse_entered := false

func _ready() -> void:
	if proxy:
		SignalHelper.persist(proxy.mouse_entered, _handle_mouse_entered)
		SignalHelper.persist(proxy.mouse_exited, _handle_mouse_exited)

func _input(event: InputEvent) -> void:
	if _validate_mouse_click(event):
		print("Flipping %s by proxy" % check_box.name)
		check_box.button_pressed = not check_box.button_pressed

func _validate_mouse_click(event: InputEvent) -> InputEventMouseButton:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and _mouse_entered and check_box:
				return event as InputEventMouseButton

	return null

func _handle_mouse_entered() -> void:
	_mouse_entered = true

func _handle_mouse_exited() -> void:
	_mouse_entered = false
