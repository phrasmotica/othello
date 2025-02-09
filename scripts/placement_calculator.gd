@tool
class_name PlacementCalculator extends Node

@export
var cells_manager: CellsManager

var _regex_b: RegEx = RegEx.new()
var _regex_w: RegEx = RegEx.new()

func _ready() -> void:
	_regex_b.compile("^1+0$")
	_regex_w.compile("^0+1$")

func refresh() -> void:
	# check place-ability under the assumption that we have all of the cells
	for idx in cells_manager.count():
		refresh_one(idx)

func refresh_one(idx: int) -> void:
	var cell := cells_manager.get_cell(idx)

	if cell:
		cell.cannot_place = not _can_place(idx)

func _compute_neighbours(idx: int, step: int) -> Array[int]:
	var width := cells_manager.width()

	var neighbours: Array[int] = [
		idx - step * width, # above
		idx - step * (width + 1), # above-right
		idx + step, # right
		idx + step * (width + 1), # below-right
		idx + step * width, # below
		idx + step * (width - 1), # below-left
		idx - step, # left
		idx - step * (width - 1), # above-left
	]

	var existent_neighbours: Array[int] = []

	for n_idx in neighbours:
		if n_idx >= 0 and n_idx < cells_manager.count():
			existent_neighbours.append(n_idx)

	return existent_neighbours

func _compute_valid_neighbours(idx: int, step: int) -> Array[int]:
	var cell := cells_manager.get_cell(idx)
	var neighbours := _compute_neighbours(idx, step)

	var valid_neighbours: Array[int] = []

	for n_idx in neighbours:
		var next_colour := cell.next_colour as BoardCell.CounterPresence
		var n_presence := cells_manager.get_cell(n_idx).counter_presence

		if next_colour == BoardCell.CounterPresence.BLACK and n_presence == BoardCell.CounterPresence.WHITE:
			valid_neighbours.append(n_idx)

		if next_colour == BoardCell.CounterPresence.WHITE and n_presence == BoardCell.CounterPresence.BLACK:
			valid_neighbours.append(n_idx)

	return valid_neighbours

func _can_place(idx: int) -> bool:
	if cells_manager.count() <= idx:
		return false

	var cell := cells_manager.get_cell(idx)
	if cell.counter_presence != BoardCell.CounterPresence.NONE:
		return false

	var valid_neighbours := _compute_valid_neighbours(idx, 1)

	var result := valid_neighbours.size() > 0

	# TODO: cast eight "rays" outwards and check whether the cells that each ray
	# passes through match the regular expressions defined at the top, depending
	# on the colour of this cell. 0 represents a black counter, 1 a white one.

	return result
