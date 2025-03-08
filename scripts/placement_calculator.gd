@tool
class_name PlacementCalculator extends Node

@export
var ray_calculator: RayCalculator

var _board_state: BoardStateData

func connect_to_board(board: Board) -> void:
	board.state_changed.connect(_handle_state_changed)

func connect_to_board_3d(board_3d: Board3D) -> void:
	board_3d.state_changed.connect(_handle_state_changed)

func _handle_state_changed(data: BoardStateData) -> void:
	_board_state = data

func can_place(idx: int, colour: BoardStateData.CounterType) -> bool:
	var cell_data: BoardCellData = _board_state.cells_data[idx]
	if cell_data.has_counter():
		return false

	var rays := ray_calculator.get_rays(idx, colour)
	return rays.size() > 0
