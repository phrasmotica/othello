@tool
class_name BoardState extends Node

@export
var board_creator: BoardCreator

var _current_state: BoardStateData

signal state_changed(data: BoardStateData)

func _ready() -> void:
	_current_state = BoardStateData.new()

	if board_creator:
		board_creator.cell_counter_changed.connect(_handle_cell_counter_changed)

func _handle_cell_counter_changed(index: int, data: BoardCellData) -> void:
	_current_state.set_cell(index, data)

	broadcast()

func broadcast() -> void:
	state_changed.emit(_current_state)
