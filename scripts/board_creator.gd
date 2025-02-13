@tool
class_name BoardCreator extends Node

@export
var cells_parent: Node2D

@export
var cells_manager: CellsManager

@export
var cell_data_pool: CellDataPool

@export
var board_cell_scene: PackedScene

# TODO: get this from the board cell scene
const CELL_SPRITE_SIZE: int = 64

var _size: Vector2i

signal cell_changed(index: int, data: BoardCellData)
signal cell_injected(index: int, data: BoardCellData)

func render_board(size: Vector2i, scene_root: Node) -> void:
	if not cells_parent:
		return

	_size = size

	cells_manager.clear(size)

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
		current_cell.index = idx

		if is_new:
			cells_parent.add_child(current_cell)
			current_cell.owner = scene_root

		cells_manager.add(current_cell)

		if current_cell.cell_pressed.get_connections().size() <= 0:
			current_cell.cell_pressed.connect(
				func() -> void:
					_handle_cell_pressed(idx)
			)

		if current_cell.counter_changed.get_connections().size() <= 0:
			current_cell.counter_changed.connect(
				func(data: BoardCellData) -> void:
					cell_injected.emit(idx, data)
			)

	var remaining_cells := child_cells.slice(size.x * size.y)
	for cell in remaining_cells:
		cell.queue_free()

func inject(state: BoardStateData) -> void:
	if state:
		print("Injecting data for %d cell(s) from %s" % [state.cells_data.size(), state.resource_path])
	else:
		print("Clearing initial state")

	var cell_count := cells_manager.count()

	for i in cell_count:
		var data := cell_data_pool.empty

		if state and state.cells_data.has(i):
			data = state.cells_data[i]

		var cell := cells_manager.get_cell(i)
		cell.cell_data = data

		cell_injected.emit(i, data)

func _handle_cell_pressed(idx: int) -> void:
	var cell := cells_manager.get_cell(idx)
	cell.place_counter(cell_data_pool.get_next())

	cell_changed.emit(idx, cell.cell_data)
