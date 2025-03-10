@tool
class_name CellsManager extends Node

var _size: Vector2i
var _cells: Array[BoardCell] = []

func clear(size: Vector2i) -> void:
	_cells.clear()

	_size = size

func add(cell: BoardCell) -> void:
	_cells.append(cell)

func set_next_colour(colour: BoardStateData.CounterType) -> void:
	for idx in count():
		var cell := get_cell(idx)
		cell.next_colour = colour

func get_cell(idx: int) -> BoardCell:
	if idx < 0 or idx >= _cells.size():
		return null

	return _cells[idx]

func get_cell_at(x_pos: int, y_pos: int) -> BoardCell:
	if not cell_exists(x_pos, y_pos):
		return null

	var idx := y_pos * width() + x_pos
	return get_cell(idx)

func get_random_placeable_cell() -> BoardCell:
	var r := _get_random_index()
	return get_cell(r) if r >= 0 else null

func _get_random_index() -> int:
	var indexes: Array[int] = []

	for idx in count():
		var cell := get_cell(idx)
		if not cell.cannot_place:
			indexes.append(idx)

	if indexes.size() <= 0:
		return -1

	var r: int = indexes.pick_random()
	return r

func cell_exists(x_pos: int, y_pos: int) -> bool:
	return x_pos >= 0 and x_pos < width() and y_pos >= 0 and y_pos < _height()

func count() -> int:
	return _cells.size()

func width() -> int:
	return _size.x if _size else 0

func _height() -> int:
	return _size.y if _size else 0
