extends HBoxContainer

@export
var camera_rig: CameraRig

@onready
var left_button: Button = %LeftButton

@onready
var right_button: Button = %RightButton

signal left_pressed
signal right_pressed

func _ready() -> void:
	if left_button:
		left_button.pressed.connect(_handle_left_pressed)

	if right_button:
		right_button.pressed.connect(_handle_right_pressed)

func _handle_left_pressed() -> void:
	if camera_rig:
		camera_rig.current_position -= 1

	left_pressed.emit()

func _handle_right_pressed() -> void:
	if camera_rig:
		camera_rig.current_position += 1

	right_pressed.emit()
