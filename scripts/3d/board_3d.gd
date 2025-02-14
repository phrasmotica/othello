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
var cells_manager_3d: CellsManager3D = %CellsManager3D

@onready
var cell_data_pool: CellDataPool = %CellDataPool

signal cell_changed(index: int, data: BoardCellData)

func _ready() -> void:
	# board_state.cell_changed.connect(cell_changed.emit)
	# board_state.state_changed.connect(state_changed.emit)

	_initialise()

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

func play_random() -> void:
	var cell := cells_manager_3d.get_random_placeable_cell_3d()

	if cell:
		cell.place_counter(cell_data_pool.get_next())

		cell_changed.emit(cell.index, cell.cell_data)
