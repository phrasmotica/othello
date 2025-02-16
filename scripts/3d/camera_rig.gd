@tool
extends Node3D

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

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	rotation_degrees.y = int(current_position * y_interval_degrees) % 360
