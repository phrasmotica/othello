@tool
class_name RayCalculator extends Node

@export
var cells_manager: CellsManager

var _size: Vector2i
var _empty_cell_code := "E"
var _missing_cell_code := "N"

var _regex_b: RegEx = RegEx.new()
var _regex_w: RegEx = RegEx.new()

var _placement_checkers := {
	BoardCell.CounterType.BLACK: _regex_b,
	BoardCell.CounterType.WHITE: _regex_w,
}

signal requested_flips(indexes: Array[int])

func _ready() -> void:
	_regex_b.compile("^1+0")
	_regex_w.compile("^0+1")

func provide_size(size: Vector2i) -> void:
	_size = size

func get_rays(idx: int, cell: BoardCell) -> Array[String]:
	var pos := _get_idx_as_pos(idx)

	var strings := [
		_encode_ray_cells(pos, 0, -1),
		_encode_ray_cells(pos, 1, -1),
		_encode_ray_cells(pos, 1, 0),
		_encode_ray_cells(pos, 1, 1),
		_encode_ray_cells(pos, 0, 1),
		_encode_ray_cells(pos, -1, 1),
		_encode_ray_cells(pos, -1, 0),
		_encode_ray_cells(pos, -1, -1),
	]

	var result: Array[String] = []

	var regex: RegEx = _placement_checkers[cell.next_colour]

	for s in strings:
		if regex.search(s):
			result.append(s)

	return result

func compute_flips(idx: int) -> void:
	var cell := cells_manager.get_cell(idx)

	var indexes: Array[int] = []

	var pos := _get_idx_as_pos(idx)

	var offsets: Array[Vector2i] = [
		Vector2i(0, -1),
		Vector2i(1, -1),
		Vector2i(1, 0),
		Vector2i(1, 1),
		Vector2i(0, 1),
		Vector2i(-1, 1),
		Vector2i(-1, 0),
		Vector2i(-1, -1),
	]

	# use counter presence as the key here, because that's the colour that
	# has already been put into the cell
	var regex: RegEx = _placement_checkers[cell.counter_presence]

	for o in offsets:
		var encoded_ray_cells := _encode_ray_cells(pos, o.x, o.y)
		# print(encoded_ray_cells)

		var search := regex.search(encoded_ray_cells)
		if search:
			var ray_cells := _compute_ray_cells(pos, o.x, o.y)

			var search_length := search.get_end() - search.get_start()

			# we use search_length - 1 because we don't need to flip the last
			# counter in the sequence
			ray_cells = ray_cells.slice(0, search_length - 1)

			print(ray_cells)

			indexes.append_array(ray_cells)

	if indexes.size() > 0:
		requested_flips.emit(indexes)

func _compute_ray_cells(pos: Vector2i, offset_x: int, offset_y: int) -> Array[int]:
	var indexes: Array[int] = []

	var next_x_pos := pos.x + offset_x
	var next_y_pos := pos.y + offset_y

	while cells_manager.cell_exists(next_x_pos, next_y_pos):
		var idx := _get_pos_as_idx(Vector2i(next_x_pos, next_y_pos))
		indexes.append(idx)

		next_x_pos += offset_x
		next_y_pos += offset_y

	return indexes

func _encode_ray_cells(pos: Vector2i, offset_x: int, offset_y: int) -> String:
	var result := ""

	var next_x_pos := pos.x
	var next_y_pos := pos.y

	while cells_manager.cell_exists(next_x_pos, next_y_pos):
		next_x_pos += offset_x
		next_y_pos += offset_y

		var idx := _get_pos_as_idx(Vector2i(next_x_pos, next_y_pos))
		result = result + _encode_cell(idx)

	return result.replace(_missing_cell_code, "")

func _encode_cell(idx: int) -> String:
	var cell := cells_manager.get_cell(idx) if cells_manager else null
	if not cell:
		return _missing_cell_code

	if cell.counter_presence == BoardCell.CounterPresence.NONE:
		return _empty_cell_code

	return str(cell.counter_presence)

func _get_idx_as_pos(idx: int) -> Vector2i:
	var x_pos := idx % _size.x
	var y_pos := int(float(idx) / float(_size.x))

	return Vector2i(x_pos, y_pos)

func _get_pos_as_idx(pos: Vector2i) -> int:
	return pos.x + _size.x * pos.y
