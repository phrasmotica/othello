@tool
class_name CellsManager extends Node2D

var _size: Vector2i
var _cells: Array[BoardCell] = []

func clear(size: Vector2i) -> void:
	_cells.clear()

	_size = size

func add(cell: BoardCell) -> void:
	_cells.append(cell)

func get_cell(idx: int) -> BoardCell:
	if idx < 0 or idx >= _cells.size():
		return null

	return _cells[idx]

func get_cell_at(x_pos: int, y_pos: int) -> BoardCell:
	if not cell_exists(x_pos, y_pos):
		return null

	var idx := y_pos * width() + x_pos
	return get_cell(idx)

func cell_exists(x_pos: int, y_pos: int) -> bool:
	return x_pos >= 0 and x_pos < width() and y_pos >= 0 and y_pos < _height()

func count() -> int:
	return _cells.size()

func width() -> int:
	return _size.x if _size else 0

func _height() -> int:
	return _size.y if _size else 0
