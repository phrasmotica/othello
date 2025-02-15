@tool
class_name CounterPreview3D extends Node3D

@export
var is_white := false:
	set(value):
		is_white = value

		_refresh()

@onready
var counter_halves: CounterHalves = %CounterHalves

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	if counter_halves:
		counter_halves.is_white = is_white
