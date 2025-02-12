@tool
class_name PlacementCalculator extends Node

@export
var cells_manager: CellsManager

@export
var ray_calculator: RayCalculator

func refresh() -> void:
	# check place-ability under the assumption that we have all of the cells
	for idx in cells_manager.count():
		refresh_one(idx)

func refresh_one(idx: int) -> void:
	var cell := cells_manager.get_cell(idx)

	if cell:
		cell.cannot_place = not _can_place(idx)

func get_plays() -> int:
	var count := 0

	for idx in cells_manager.count():
		if _can_place(idx):
			count += 1

	return count

func _can_place(idx: int) -> bool:
	if cells_manager.count() <= idx:
		return false

	var cell := cells_manager.get_cell(idx)
	if cell.cell_data.has_counter():
		return false

	# cast eight "rays" outwards and check whether the cells that each ray
	# passes through match the regular expressions defined at the top, depending
	# on the colour of this cell. 0 represents a black counter, 1 a white one.
	var rays := ray_calculator.get_rays(idx, cell)
	return rays.size() > 0
