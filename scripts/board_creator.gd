@tool
class_name BoardCreator extends Node

@export
var cells_parent: Node2D

@export
var board_cell_scene: PackedScene

# TODO: get this from the board cell scene
const CELL_SPRITE_SIZE: int = 64

signal cell_counter_changed(index: int, type: BoardCell.CounterPresence)

func set_next_colour(type: BoardCell.CounterType) -> void:
	var child_cells := cells_parent.get_children()

	for c in child_cells:
		(c as BoardCell).next_colour = type

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

		current_cell.position = CELL_SPRITE_SIZE * Vector2(x_pos, y_pos)

		if is_new:
			cells_parent.add_child(current_cell)
			current_cell.owner = scene_root

		if current_cell.counter_changed.get_connections().size() <= 0:
			current_cell.counter_changed.connect(
				func(type: BoardCell.CounterPresence) -> void:
					cell_counter_changed.emit(idx, type)
			)

	var remaining_cells := child_cells.slice(size.x * size.y)
	for cell in remaining_cells:
		cell.queue_free()
