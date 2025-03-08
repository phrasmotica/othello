class_name CellToggler extends Node

@export
var placement_calculator: PlacementCalculator

var _board_state: BoardStateData

signal refreshed_cell(idx: int, can_place: bool)

func connect_to_board_3d(board_3d: Board3D) -> void:
	board_3d.state_changed.connect(_handle_state_changed)

	refreshed_cell.connect(board_3d.enable_cell)

func _handle_state_changed(data: BoardStateData) -> void:
	_board_state = data

func refresh_for(colour: BoardStateData.CounterType) -> void:
	# check place-ability under the assumption that we have all of the cells
	for idx: int in _board_state.cells_data.keys():
		_refresh_one(colour, idx)

func _refresh_one(colour: BoardStateData.CounterType, idx: int) -> void:
	var can_place := placement_calculator.can_place(idx, colour)

	refreshed_cell.emit(idx, can_place)
