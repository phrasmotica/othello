@tool
class_name CellToggler extends Node

@export
var state_tracker: BoardStateTracker

@export
var placement_calculator: PlacementCalculator

signal refreshed_cell(idx: int, can_place: bool)

func connect_to_board_3d(board_3d: Board3D) -> void:
	refreshed_cell.connect(board_3d.enable_cell)

func refresh_for(colour: BoardStateData.CounterType) -> void:
	# check place-ability under the assumption that we have all of the cells
	for idx: int in state_tracker.get_indexes():
		_refresh_one(colour, idx)

func _refresh_one(colour: BoardStateData.CounterType, idx: int) -> void:
	var can_place := placement_calculator.can_place(idx, colour)

	refreshed_cell.emit(idx, can_place)
