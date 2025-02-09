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
