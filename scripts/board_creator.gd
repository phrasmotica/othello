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

func can_place(idx: int) -> bool:
	if _cells.size() <= idx:
		return false

	var cell := _cells[idx]
	if cell.counter_presence != BoardCell.CounterPresence.NONE:
		return false

	var neighbours: Array[int] = [
		idx - _size.x, # above
		idx - _size.x + 1, # above-right
		idx + 1, # right
		idx + _size.x + 1, # below-right
		idx + _size.x, # below
		idx + _size.x - 1, # below-left
		idx - 1, # left
		idx - _size.x - 1, # above-left
	]

	for n_idx in neighbours:
		if n_idx < 0 or n_idx >= _cells.size():
			continue

		var next_colour := cell.next_colour as BoardCell.CounterPresence
		var n_presence := _cells[n_idx].counter_presence

		if next_colour == BoardCell.CounterPresence.BLACK and n_presence == BoardCell.CounterPresence.WHITE:
			return true

		if next_colour == BoardCell.CounterPresence.WHITE and n_presence == BoardCell.CounterPresence.BLACK:
			return true

	# TODO: check that the following are also true:
	# 1. continuing past the valid neighbour, there is another cell C occupied by the same colour as our colour
	# 2. all cells between this one and C are occupied
	return false
