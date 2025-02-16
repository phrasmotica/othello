@tool
class_name CellsParent3D extends Node3D

@export
var board_cell_scene: PackedScene

signal cell_confirmed(index: int, data: BoardCellData)

func render_cell(size: Vector2i, scene_root: Node, idx: int) -> BoardCell3D:
	var child_cells := get_children()

	var is_new = false
	var current_cell: BoardCell3D = null

	if child_cells.size() > idx:
		current_cell = child_cells[idx] as BoardCell3D
	else:
		is_new = true
		current_cell = board_cell_scene.instantiate()

	current_cell.name = "Cell3D" + str(idx)

	var x_pos := idx % size.x
	var z_pos := int(float(idx) / float(size.x))

	# MEDIUM: get these from the cell scene
	var cell_width := 1.0
	var cell_depth := 1.0

	var start_x := (cell_width - size.x) / 2.0
	var start_z := (cell_depth - size.y) / 2.0

	# ensures the cells are all centred around the origin
	var start_pos := Vector3(start_x, 0, start_z)

	current_cell.position = start_pos + Vector3(x_pos, 0, z_pos)
	current_cell.set_pos(x_pos, z_pos)

	current_cell.index = idx

	if is_new:
		add_child(current_cell)
		current_cell.owner = scene_root

	if current_cell.counter_confirmed.get_connections().size() <= 0:
		current_cell.counter_confirmed.connect(
			func(data: BoardCellData) -> void:
				cell_confirmed.emit(idx, data)
		)

	return current_cell

func clean(size: Vector2i) -> Array:
	var child_cells := get_children()
	var remaining_cells := child_cells.slice(size.x * size.y)

	for cell in remaining_cells:
		cell.queue_free()

	return remaining_cells
