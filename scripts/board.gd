@tool
class_name Board extends Node2D

@export
var initial_state: BoardStateData:
	set(value):
		if initial_state != value:
			initial_state = value

			_initialise()

@export_group("External Dependencies")

@export
var turn_tracker: TurnTracker

@export
var ray_calculator: RayCalculator

@export
var score_ui: ScoreUI

@export
var game_buttons: GameButtons

@export
var debug_handler: DebugHandler

@onready
var board_creator: BoardCreator = %BoardCreator

@onready
var board_state: BoardState = %BoardState

@onready
var cell_data_pool: CellDataPool = %CellDataPool

signal cell_changed(index: int, data: BoardCellData)
signal state_changed(data: BoardStateData)
signal board_reset

func _ready() -> void:
	if turn_tracker:
		turn_tracker.starting_colour_changed.connect(_handle_starting_colour_changed)
		turn_tracker.next_colour_changed.connect(_handle_next_colour_changed)

	if ray_calculator:
		ray_calculator.requested_flips.connect(board_creator.perform_flips)

	if score_ui:
		score_ui.ready.connect(_handle_score_ui_ready)

	board_state.cell_changed.connect(cell_changed.emit)
	board_state.state_changed.connect(state_changed.emit)

	if not Engine.is_editor_hint():
		if turn_tracker:
			board_creator.turn_ended.connect(turn_tracker.next)

		if game_buttons:
			game_buttons.restarted.connect(_handle_restarted)

		if debug_handler:
			debug_handler.play_random.connect(_handle_play_random)

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

func _handle_starting_colour_changed(colour: BoardStateData.CounterType) -> void:
	_accept_next_colour(colour)

func _handle_next_colour_changed(colour: BoardStateData.CounterType) -> void:
	_accept_next_colour(colour)

func _accept_next_colour(colour: BoardStateData.CounterType) -> void:
	if board_creator:
		board_creator.set_next_colour(colour)

	if board_state:
		board_state.set_next_colour(colour)

	if cell_data_pool:
		cell_data_pool.next_colour = colour

func _handle_score_ui_ready() -> void:
	if board_state:
		board_state.broadcast()

func _handle_restarted() -> void:
	if board_creator:
		board_creator.inject(initial_state)

	board_reset.emit()

func _handle_play_random() -> void:
	if board_creator:
		board_creator.play_random()

func enable_cell(idx: int, enabled: bool) -> void:
	board_creator.enable_cell(idx, enabled)
