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
