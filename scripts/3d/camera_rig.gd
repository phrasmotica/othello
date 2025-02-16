@tool
class_name CameraRig extends Node3D

@export_range(30, 180)
var y_interval_degrees := 90.0:
	set(value):
		y_interval_degrees = value

		_refresh()

@export
var current_position := 0:
	set(value):
		current_position = value

		_refresh()

@export
var use_tweening := false

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	if not Engine.is_editor_hint() and use_tweening:
		_rotate()
	else:
		rotation_degrees.y = int(current_position * y_interval_degrees) % 360

func _rotate() -> void:
	var current_rotation := rotation_degrees.y
	var final_rotation := current_position * y_interval_degrees

	print("Rotating camera rig from %.0f to %.0f" % [current_rotation, final_rotation])

	var tween := create_tween()

	tween.tween_property(
		self,
		"rotation_degrees:y",
		final_rotation,
		0.2
	)

	tween.tween_callback(
		func() -> void:
			print("Finished rotating camera rig from %.0f to %.0f" % [current_rotation, final_rotation])
	)
