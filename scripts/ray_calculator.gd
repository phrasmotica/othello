@tool
class_name RayCalculator extends Node

var _board_state: BoardStateData

var _empty_cell_code := "E"
var _missing_cell_code := "N"

var _regex_b: RegEx = RegEx.new()
var _regex_w: RegEx = RegEx.new()

var _placement_checkers := {
	BoardStateData.CounterType.BLACK: _regex_b,
	BoardStateData.CounterType.WHITE: _regex_w,
}

signal computed_flips(indexes: Array[int])
signal previewed_flips(indexes: Array[int])

func _ready() -> void:
	_regex_b.compile("^1+0")
	_regex_w.compile("^0+1")

func connect_to_board(board: Board) -> void:
	board.cell_changed.connect(_handle_cell_changed)
	board.state_changed.connect(_handle_state_changed)

	computed_flips.connect(board.perform_flips)

func connect_to_board_3d(board_3d: Board3D) -> void:
	board_3d.cell_highlighted.connect(_handle_cell_highlighted)
	board_3d.cell_changed.connect(_handle_cell_changed)
	board_3d.state_changed.connect(_handle_state_changed)

	computed_flips.connect(board_3d.perform_flips)
	previewed_flips.connect(board_3d.preview_flips)

func _handle_cell_highlighted(index: int) -> void:
	var indexes: Array[int] = []

	if index >= 0:
		indexes = _preview_flips(index)

	previewed_flips.emit(indexes)

func _handle_cell_changed(index: int, _data: BoardCellData) -> void:
	var indexes := _compute_flips(index)

	computed_flips.emit(indexes)

func _handle_state_changed(data: BoardStateData) -> void:
	_board_state = data

func get_rays(idx: int, next_colour: BoardStateData.CounterType) -> Array[String]:
	# cast eight "rays" outwards and check whether the cells that each ray
	# passes through match the regular expressions defined at the top, depending
	# on the colour of this cell. 0 represents a black counter, 1 a white one.

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

	var regex: RegEx = _placement_checkers[next_colour]

	for s in strings:
		if regex.search(s):
			result.append(s)

	return result

func _preview_flips(idx: int) -> Array[int]:
	if not _board_state:
		return []

	return _compute_flips_for_colour(idx, _board_state.next_colour)

func _compute_flips(idx: int) -> Array[int]:
	var cell_data := _get_cell_data(idx)

	if not cell_data:
		return []

	# use counter presence as the key here, because that's the colour that
	# has already been put into the cell
	var colour := cell_data.counter_presence as BoardStateData.CounterType

	return _compute_flips_for_colour(idx, colour)

func _compute_flips_for_colour(idx: int, colour: BoardStateData.CounterType) -> Array[int]:
	var cell_data := _get_cell_data(idx)

	if not cell_data:
		return []

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

	if _placement_checkers.has(colour):
		var regex: RegEx = _placement_checkers[colour]
		indexes = _compute_indexes(pos, offsets, regex)

	return indexes

func _compute_indexes(pos: Vector2i, offsets: Array[Vector2i], regex: RegEx) -> Array[int]:
	var indexes: Array[int] = []

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

			# print(ray_cells)

			indexes.append_array(ray_cells)

	return indexes

func _compute_ray_cells(pos: Vector2i, offset_x: int, offset_y: int) -> Array[int]:
	var indexes: Array[int] = []

	var next_x_pos := pos.x + offset_x
	var next_y_pos := pos.y + offset_y

	while _cell_exists(next_x_pos, next_y_pos):
		var idx := _get_pos_as_idx(Vector2i(next_x_pos, next_y_pos))
		indexes.append(idx)

		next_x_pos += offset_x
		next_y_pos += offset_y

	return indexes

func _encode_ray_cells(pos: Vector2i, offset_x: int, offset_y: int) -> String:
	var result := ""

	var next_x_pos := pos.x + offset_x
	var next_y_pos := pos.y + offset_y

	while _cell_exists(next_x_pos, next_y_pos):
		var idx := _get_pos_as_idx(Vector2i(next_x_pos, next_y_pos))
		result = result + _encode_cell(idx)

		next_x_pos += offset_x
		next_y_pos += offset_y

	return result.replace(_missing_cell_code, "")

func _encode_cell(idx: int) -> String:
	var cell_data := _get_cell_data(idx)
	if not cell_data:
		return _missing_cell_code

	if not cell_data.has_counter():
		return _empty_cell_code

	return str(cell_data.counter_presence)

func _get_cell_data(idx: int) -> BoardCellData:
	if _board_state.cells_data.has(idx):
		var cell_data: BoardCellData = _board_state.cells_data[idx]
		return cell_data

	return null

func _cell_exists(x_pos: int, y_pos: int) -> bool:
	return x_pos >= 0 and x_pos < width() and y_pos >= 0 and y_pos < _height()

func width() -> int:
	return _board_state.board_size.x if _board_state else 0

func _height() -> int:
	return _board_state.board_size.y if _board_state else 0

func _get_idx_as_pos(idx: int) -> Vector2i:
	if not _board_state:
		return -Vector2i.ONE

	var x_pos := idx % _board_state.board_size.x
	var y_pos := int(float(idx) / float(_board_state.board_size.x))

	return Vector2i(x_pos, y_pos)

func _get_pos_as_idx(pos: Vector2i) -> int:
	return pos.x + _board_state.board_size.x * pos.y
