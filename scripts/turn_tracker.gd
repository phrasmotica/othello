@tool
class_name TurnTracker extends Node

@export
var starting_colour := BoardCell.CounterType.BLACK:
	set(value):
		if starting_colour != value:
			starting_colour = value

			_emit()

signal starting_colour_changed(colour: BoardCell.CounterType)

func _ready() -> void:
	get_tree().root.ready.connect(_emit)

func _emit() -> void:
	starting_colour_changed.emit(starting_colour)
