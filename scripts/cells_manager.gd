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

func count() -> int:
	return _cells.size()

func width() -> int:
	return _size.x if _size else 0
