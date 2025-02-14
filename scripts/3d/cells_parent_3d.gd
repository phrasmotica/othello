@tool
class_name CellsParent3D extends Node3D

@export
var board_cell_scene: PackedScene

signal cell_pressed(idx: int)
signal cell_injected(index: int, data: BoardCellData)

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
	var y_pos := int(float(idx) / float(size.x))

	current_cell.position = Vector3(x_pos, 0, y_pos)
	current_cell.set_pos(x_pos, y_pos)

	current_cell.index = idx

	if is_new:
		add_child(current_cell)
		current_cell.owner = scene_root

	if current_cell.cell_pressed.get_connections().size() <= 0:
		current_cell.cell_pressed.connect(cell_pressed.emit.bind(idx))

	if current_cell.counter_changed.get_connections().size() <= 0:
		current_cell.counter_changed.connect(
			func(data: BoardCellData) -> void:
				cell_injected.emit(idx, data)
		)

	return current_cell

func clean(size: Vector2i) -> Array:
	var child_cells := get_children()
	var remaining_cells := child_cells.slice(size.x * size.y)

	for cell in remaining_cells:
		cell.queue_free()

	return remaining_cells
