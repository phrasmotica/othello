@tool
class_name BoardCreator3D extends BoardCreator

@export
var cells_parent_3d: CellsParent3D

@export
var cells_manager_3d: CellsManager3D

func _ready() -> void:
	if cells_parent_3d:
		cells_parent_3d.cell_injected.connect(cell_injected.emit)
		cells_parent_3d.cell_pressed.connect(_handle_cell_pressed)

func inject(state: BoardStateData, scene_root: Node) -> void:
	if state:
		print("Injecting data for %d cell(s) from %s" % [state.cells_data.size(), state.resource_path])
		_render_board(state.board_size, scene_root)
	else:
		print("Clearing initial state")
		_render_board(Vector2i.ZERO, scene_root)

	var cell_count := cells_manager_3d.count()

	for i in cell_count:
		var data := cell_data_pool.empty

		if state and state.cells_data.has(i):
			data = state.cells_data[i]

		var cell := cells_manager_3d.get_cell_3d(i)
		cell.cell_data = data

		cell_injected.emit(i, data)

## Overrides the method in BoardCreator class.
func _render_board(size: Vector2i, scene_root: Node) -> void:
	if not cells_parent_3d:
		return

	cells_manager_3d.clear(size)

	for idx in size.x * size.y:
		var current_cell := cells_parent_3d.render_cell(size, scene_root, idx)
		cells_manager_3d.add_3d(current_cell)

	cells_parent_3d.clean(size)
