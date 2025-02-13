@tool
class_name Board extends Node2D

@export
var initial_state: BoardStateData:
	set(value):
		if initial_state != value:
			initial_state = value

			_initialise()

@onready
var board_creator: BoardCreator = %BoardCreator

@onready
var board_state: BoardState = %BoardState

@onready
var cells_manager: CellsManager = %CellsManager

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

func _initialise() -> void:
	if board_creator:
		board_creator.render_board(initial_state.board_size, self)

		_connect_initial_state()

func _connect_initial_state() -> void:
	if initial_state and initial_state.changed.get_connections().size() <= 0:
		initial_state.changed.connect(
			func() -> void:
				board_creator.inject(initial_state)
		)

	board_creator.inject(initial_state)

func set_next_colour(colour: BoardStateData.CounterType) -> void:
	if cells_manager:
		cells_manager.set_next_colour(colour)

	if board_state:
		board_state.set_next_colour(colour)

	if cell_data_pool:
		cell_data_pool.next_colour = colour

func broadcast_state() -> void:
	if board_state:
		board_state.broadcast()

func restart() -> void:
	if board_creator:
		board_creator.inject(initial_state)

	board_reset.emit()

func play_random() -> void:
	var cell := cells_manager.get_random_placeable_cell()

	if cell:
		cell.place_counter(cell_data_pool.get_next())

		cell_changed.emit(cell.index, cell.cell_data)

func perform_flips(indexes: Array[int]) -> void:
	if indexes.size() < 0:
		return

	for i in indexes:
		var cell := cells_manager.get_cell(i)
		cell.cell_data = cell_data_pool.flip(cell.cell_data)

		board_state.set_cell(i, cell.cell_data, false)

	flips_finished.emit(indexes)

func enable_cell(idx: int, enabled: bool) -> void:
	var cell := cells_manager.get_cell(idx)
	cell.cannot_place = not enabled
