@tool
class_name BoardStateTracker extends Node

var _board_state: BoardStateData

func connect_to_board_3d(board_3d: Board3D) -> void:
	board_3d.state_changed.connect(_handle_state_changed)

func _handle_state_changed(data: BoardStateData) -> void:
	_board_state = data

func width() -> int:
	return _board_state.board_size.x if _board_state else 0

func height() -> int:
	return _board_state.board_size.y if _board_state else 0

func get_indexes() -> Array:
	return _board_state.cells_data.keys()

func cell_exists(x_pos: int, y_pos: int) -> bool:
	return (
		x_pos >= 0 and x_pos < width() and
		y_pos >= 0 and y_pos < height()
	)

func get_cell(idx: int) -> BoardCellData:
	return _board_state.get_cell(idx)

func has_counter(idx: int) -> bool:
	var cell := get_cell(idx)
	if cell:
		return cell.has_counter()

	return false

func get_idx_as_pos(idx: int) -> Vector2i:
	if not _board_state:
		return -Vector2i.ONE

	var w := width()

	var x_pos := idx % w
	var y_pos := int(float(idx) / float(w))

	return Vector2i(x_pos, y_pos)

func get_pos_as_idx(pos: Vector2i) -> int:
	return pos.x + width() * pos.y
