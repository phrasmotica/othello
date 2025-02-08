@tool
class_name BoardCreator extends Node

@export
var cells_parent: Node2D

@export
var board_cell_scene: PackedScene

func render_board(size: Vector2i, scene_root: Node) -> void:
	if not cells_parent:
		return

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

		current_cell.position = 64 * Vector2(x_pos, y_pos)

		if is_new:
			cells_parent.add_child(current_cell)
			current_cell.owner = scene_root

	var remaining_cells := child_cells.slice(size.x * size.y)
	for cell in remaining_cells:
		cell.queue_free()
