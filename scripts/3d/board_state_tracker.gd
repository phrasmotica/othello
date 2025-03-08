@tool
class_name BoardStateTracker extends Node

var _board_state: BoardStateData

func connect_to_board_3d(board_3d: Board3D) -> void:
	board_3d.state_changed.connect(_handle_state_changed)

func _handle_state_changed(data: BoardStateData) -> void:
	_board_state = data

func get_indexes() -> Array:
	return _board_state.cells_data.keys()

func has_counter(idx: int) -> bool:
	var cell := _board_state.get_cell(idx)
	if cell:
		return cell.has_counter()

	return false
