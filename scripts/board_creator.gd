@tool
class_name BoardCreator extends Node

@export
var cells_parent: Node2D

@export
var board_cell_scene: PackedScene

# TODO: get this from the board cell scene
const CELL_SPRITE_SIZE: int = 64

var _size: Vector2i
var _cells: Array[BoardCell] = []

signal cell_counter_changed(index: int, type: BoardCell.CounterPresence)

func set_next_colour(type: BoardCell.CounterType) -> void:
	for idx in len(_cells):
		var cell = _cells[idx]
		cell.next_colour = type
		cell.cannot_place = not can_place(idx)

func render_board(size: Vector2i, scene_root: Node) -> void:
	if not cells_parent:
		return

	_size = size
	_cells.clear()

	var child_cells := cells_parent.get_children()

	for idx in size.x * size.y:
		var is_new = false
		var current_cell: BoardCell = null

		if child_cells.size() > idx:
			current_cell = child_cells[idx] as BoardCell
		else:
			is_new = true
			current_cell = board_cell_scene.instantiate()

		current_cell.name = "Cell" + str(idx)

		var x_pos := idx % size.x
		var y_pos := int(float(idx) / float(size.x))

		current_cell.position = CELL_SPRITE_SIZE * Vector2(x_pos, y_pos)
		current_cell.counter_presence = get_default_counter(size, x_pos, y_pos)
		current_cell.index = idx

		if is_new:
			cells_parent.add_child(current_cell)
			current_cell.owner = scene_root

		_cells.append(current_cell)

		if current_cell.counter_changed.get_connections().size() <= 0:
			current_cell.counter_changed.connect(
				func(type: BoardCell.CounterPresence) -> void:
					cell_counter_changed.emit(idx, type)
			)

	var remaining_cells := child_cells.slice(size.x * size.y)
	for cell in remaining_cells:
		cell.queue_free()

	# check place-ability now that we have all of the cells
	for idx in size.x * size.y:
		_cells[idx].cannot_place = not can_place(idx)

func get_default_counter(size: Vector2i, x_pos: int, y_pos: int) -> BoardCell.CounterPresence:
	var half_x := int(float(size.x) / 2)
	var half_y := int(float(size.y) / 2)

	var starts_filled := [half_x, half_x - 1].has(x_pos) and [half_y, half_y - 1].has(y_pos)
	if starts_filled:
		if (x_pos + y_pos) % 2 != 0:
			return BoardCell.CounterPresence.WHITE

		return BoardCell.CounterPresence.BLACK

	return BoardCell.CounterPresence.NONE

func _compute_neighbours(idx: int, step: int) -> Array[int]:
	var neighbours: Array[int] = [
		idx - step * _size.x, # above
		idx - step * (_size.x + 1), # above-right
		idx + step, # right
		idx + step * (_size.x + 1), # below-right
		idx + step * _size.x, # below
		idx + step * (_size.x - 1), # below-left
		idx - step, # left
		idx - step * (_size.x - 1), # above-left
	]

	var existent_neighbours: Array[int] = []

	for n_idx in neighbours:
		if n_idx >= 0 and n_idx < _cells.size():
			existent_neighbours.append(n_idx)

	return existent_neighbours

func _compute_valid_neighbours(idx: int, step: int) -> Array[int]:
	var cell := _cells[idx]
	var neighbours := _compute_neighbours(idx, step)

	var valid_neighbours: Array[int] = []

	for n_idx in neighbours:
		var next_colour := cell.next_colour as BoardCell.CounterPresence
		var n_presence := _cells[n_idx].counter_presence

		# TODO: check that the following are also true:
		# 1. continuing past the valid neighbour, there is another cell C occupied by the same colour as our colour
		# 2. all cells between this one and C are occupied

		if next_colour == BoardCell.CounterPresence.BLACK and n_presence == BoardCell.CounterPresence.WHITE:
			valid_neighbours.append(n_idx)

		if next_colour == BoardCell.CounterPresence.WHITE and n_presence == BoardCell.CounterPresence.BLACK:
			valid_neighbours.append(n_idx)

	return valid_neighbours

func can_place(idx: int) -> bool:
	if _cells.size() <= idx:
		return false

	var cell := _cells[idx]
	if cell.counter_presence != BoardCell.CounterPresence.NONE:
		return false

	var valid_neighbours := _compute_valid_neighbours(idx, 1)

	var result := valid_neighbours.size() > 0

	# TODO: if there is a valid neighbour C, we can check its immediate
	# neighbour in the same direction D. If D is occupied with a different
	# colour to C, then we would have a trivial BWB or WBW sequence, so the
	# placement is valid. However its colour is the same as C, we need to keep
	# checking neighbours in that direction until we hit a different colour.
	# Only then would the placement be valid.

	return result
