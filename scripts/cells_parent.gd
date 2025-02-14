@tool
class_name CellsParent extends Node2D

@export
var board_cell_scene: PackedScene

# TODO: get this from the board cell scene
const CELL_SPRITE_SIZE: int = 64

signal cell_pressed(idx: int)
signal cell_injected(index: int, data: BoardCellData)

func render_cell(size: Vector2i, scene_root: Node, idx: int) -> BoardCell:
	var child_cells := get_children()

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
