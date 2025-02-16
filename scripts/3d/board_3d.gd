@tool
class_name Board3D extends Node3D

@export
var initial_state: BoardStateData:
	set(value):
		if initial_state != value:
			initial_state = value

			_initialise()

@onready
var board_creator: BoardCreator3D = %BoardCreator3D

@onready
var board_state: BoardState = %BoardState

@onready
var cells_manager_3d: CellsManager3D = %CellsManager3D

@onready
var cell_data_pool: CellDataPool = %CellDataPool

signal cell_changed(index: int, data: BoardCellData)
signal state_changed(data: BoardStateData)
signal flips_finished(indexes: Array[int])
signal board_reset

func _ready() -> void:
	board_state.cell_changed.connect(cell_changed.emit)
	board_state.state_changed.connect(state_changed.emit)

	_initialise()

	if not Engine.is_editor_hint():
		Globals.init_finished = true
		print("Init finished")

func _initialise() -> void:
	_inject_state()

	if Engine.is_editor_hint():
		_connect_initial_state()

func _inject_state() -> void:
	if board_creator:
		board_creator.inject(initial_state, self)

func _connect_initial_state() -> void:
	if initial_state and initial_state.changed.get_connections().size() <= 0:
		initial_state.changed.connect(_inject_state)

func set_next_colour(colour: BoardStateData.CounterType) -> void:
	if cells_manager_3d:
		cells_manager_3d.set_next_colour(colour)

	if board_state:
		board_state.set_next_colour(colour)

	if cell_data_pool:
		cell_data_pool.next_colour = colour

func broadcast_state() -> void:
	if board_state:
		board_state.broadcast()

func restart() -> void:
	if board_creator:
		board_creator.inject(initial_state, self)

	board_reset.emit()

func play_at(cell: BoardCell3D) -> void:
	if cell:
		print("Placing counter in cell %d" % cell.index)

		cell.show_preview = false
		cell.place_counter(cell_data_pool.get_next())

func play_random() -> void:
	var cell := cells_manager_3d.get_random_placeable_cell_3d()

	if cell:
		print("Placing counter randomly in cell %d" % cell.index)

		cell.place_counter(cell_data_pool.get_next())

func perform_flips(indexes: Array[int]) -> void:
	if indexes.size() < 0:
		return

	for i in indexes:
		var cell := cells_manager_3d.get_cell_3d(i)
		cell.cell_data = cell_data_pool.flip(cell.cell_data)

		board_state.set_cell(i, cell.cell_data, false)

	flips_finished.emit(indexes)

func enable_cell(idx: int, enabled: bool) -> void:
	var cell := cells_manager_3d.get_cell_3d(idx)
	cell.cannot_place = not enabled

func highlight_cell(idx: int) -> void:
	for i in cells_manager_3d.count():
		var cell := cells_manager_3d.get_cell_3d(i)
		cell.show_preview = cell.index == idx
