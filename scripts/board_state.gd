@tool
class_name BoardState extends Node

@export
var board_creator: BoardCreator

var _current_state: BoardStateData

signal cell_changed(index: int, data: BoardCellData)
signal state_changed(data: BoardStateData)

func _ready() -> void:
	restart_game()

	if board_creator:
		board_creator.cell_confirmed.connect(_handle_cell_confirmed)
		board_creator.cell_injected.connect(_handle_cell_injected)

func restart_game() -> void:
	_current_state = BoardStateData.new()

func set_next_colour(type: BoardStateData.CounterType) -> void:
	_current_state.next_colour = type
	_broadcast()

func _handle_cell_confirmed(index: int, data: BoardCellData) -> void:
	set_cell(index, data, true)

func _handle_cell_injected(index: int, data: BoardCellData) -> void:
	set_cell(index, data, false)

func set_cell(index: int, data: BoardCellData, emit_changed: bool) -> void:
	_current_state.set_cell(index, data)
	_broadcast()

	if emit_changed:
		cell_changed.emit(index, data)

func _broadcast() -> void:
	state_changed.emit(_current_state)
