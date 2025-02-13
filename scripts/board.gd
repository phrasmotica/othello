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
	if board_creator:
		board_creator.set_next_colour(colour)

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
	if board_creator:
		board_creator.play_random()

func perform_flips(indexes: Array[int]) -> void:
	board_creator.perform_flips(indexes)
	flips_finished.emit(indexes)

func enable_cell(idx: int, enabled: bool) -> void:
	board_creator.enable_cell(idx, enabled)
