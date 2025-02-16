@tool
class_name CounterHalves extends Node3D

@export
var is_preview := false:
	set(value):
		is_preview = value

		_refresh()

@export
var is_white := false:
	set(value):
		is_white = value

		_refresh()

@export_group("Animation")

@export_range(0.1, 0.5)
var flip_duration := 0.5

@onready
var main: Node3D = %Main

@onready
var preview: Node3D = %Preview

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	if main:
		main.visible = not is_preview

	if preview:
		preview.visible = is_preview

	rotation_degrees.x = 180 if is_white else 0

func rotate_tween(tween: Tween) -> void:
	var final_rotation := int(rotation_degrees.x + 180) % 360

	tween.tween_property(
		self,
		"rotation_degrees:x",
		final_rotation,
		flip_duration
	)

	tween.tween_callback(
		func() -> void:
			rotation_degrees.x = final_rotation

			var debug_name := get_meta("debug_name") as String
			print("Finished rotating %s to %.1f" % [debug_name, final_rotation])
	)
