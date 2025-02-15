@tool
class_name BoardCreator extends Node

@export
var cells_parent: CellsParent

@export
var cells_manager: CellsManager

@export
var cell_data_pool: CellDataPool

signal cell_confirmed(index: int, data: BoardCellData)
signal cell_injected(index: int, data: BoardCellData)

func _ready() -> void:
	if cells_parent:
		cells_parent.cell_injected.connect(cell_injected.emit)
		cells_parent.cell_pressed.connect(_handle_cell_pressed)

func inject(state: BoardStateData, scene_root: Node) -> void:
	if state:
		print("Injecting data for %d cell(s) from %s" % [state.cells_data.size(), state.resource_path])
		_render_board(state.board_size, scene_root)
	else:
		print("Clearing initial state")
		_render_board(Vector2i.ZERO, scene_root)

	var cell_count := cells_manager.count()

	for i in cell_count:
		var data := cell_data_pool.empty

		if state and state.cells_data.has(i):
			data = state.cells_data[i]

		var cell := cells_manager.get_cell(i)
		cell.cell_data = data

		cell_injected.emit(i, data)

func _render_board(size: Vector2i, scene_root: Node) -> void:
	if not cells_parent:
		return

	cells_manager.clear(size)

	for idx in size.x * size.y:
		var current_cell := cells_parent.render_cell(size, scene_root, idx)
		cells_manager.add(current_cell)

	cells_parent.clean(size)

func _handle_cell_pressed(idx: int) -> void:
	var cell := cells_manager.get_cell(idx)
	cell.place_counter(cell_data_pool.get_next())

	cell_confirmed.emit(idx, cell.cell_data)

func _handle_cell_confirmed(index: int, data: BoardCellData) -> void:
	cell_confirmed.emit(index, data)
