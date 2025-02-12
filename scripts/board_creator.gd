@tool
class_name BoardCreator extends Node

@export
var cells_parent: Node2D

@export
var cells_manager: CellsManager

@export
var placement_calculator: PlacementCalculator

@export
var ray_calculator: RayCalculator

@export
var cell_data_pool: CellDataPool

@export
var board_cell_scene: PackedScene

# TODO: get this from the board cell scene
const CELL_SPRITE_SIZE: int = 64

var _size: Vector2i

signal cell_counter_changed(index: int, data: BoardCellData)
signal turn_ended

func _ready() -> void:
	if ray_calculator:
		ray_calculator.requested_flips.connect(_handle_requested_flips)

func set_next_colour(type: BoardCell.CounterType) -> void:
	cell_data_pool.next_colour = type

	for idx in cells_manager.count():
		var cell := cells_manager.get_cell(idx)
		cell.next_colour = type

		placement_calculator.refresh_one(idx)

func render_board(size: Vector2i, scene_root: Node) -> void:
	if not cells_parent:
		return

	_size = size

	cells_manager.clear(size)
	ray_calculator.provide_size(size)

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
					_handle_counter_changed(idx, data)
			)

	var remaining_cells := child_cells.slice(size.x * size.y)
	for cell in remaining_cells:
		cell.queue_free()

	# check place-ability now that we have all of the cells
	placement_calculator.refresh()

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

		cell_counter_changed.emit(i, data)

func play_random() -> void:
	var cell := cells_manager.get_random_placeable_cell()

	if cell:
		cell.place_counter(cell_data_pool.get_next())

func _handle_cell_pressed(idx: int) -> void:
	var cell := cells_manager.get_cell(idx)
	cell.place_counter(cell_data_pool.get_next())

func _handle_counter_changed(idx: int, data: BoardCellData) -> void:
	cell_counter_changed.emit(idx, data)

	if ray_calculator:
		ray_calculator.compute_flips(idx)

func _handle_requested_flips(indexes: Array[int]) -> void:
	for i in indexes:
		var cell := cells_manager.get_cell(i)
		cell.cell_data = cell_data_pool.flip(cell.cell_data)

		cell_counter_changed.emit(i, cell.cell_data)

	turn_ended.emit()
