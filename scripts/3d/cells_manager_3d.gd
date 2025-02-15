@tool
class_name CellsManager3D extends CellsManager

var _cells_3d: Array[BoardCell3D] = []

func clear(size: Vector2i) -> void:
	_cells_3d.clear()

	_size = size

func add_3d(cell: BoardCell3D) -> void:
	_cells_3d.append(cell)

func set_next_colour(colour: BoardStateData.CounterType) -> void:
	for idx in count():
		var cell := get_cell_3d(idx)
		cell.next_colour = colour

func get_cell_3d(idx: int) -> BoardCell3D:
	if idx < 0 or idx >= count():
		return null

	return _cells_3d[idx]

func get_random_placeable_cell_3d() -> BoardCell3D:
	var r := _get_random_index()
	return get_cell_3d(r) if r >= 0 else null

func _get_random_index() -> int:
	var indexes: Array[int] = []

	for idx in count():
		var cell := get_cell_3d(idx)
		if not cell.cannot_place:
			indexes.append(idx)

	if indexes.size() <= 0:
		return -1

	var r: int = indexes.pick_random()
	return r

func count() -> int:
	return _cells_3d.size()
