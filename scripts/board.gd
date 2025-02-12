@tool
class_name Board extends Node2D

const MIN_WIDTH := 6
const MIN_HEIGHT := 6
const MAX_WIDTH := 8
const MAX_HEIGHT := 8

@export
var size: Vector2i = Vector2i(MAX_WIDTH, MAX_HEIGHT):
	set(value):
		value.x = clampi(value.x, MIN_WIDTH, MAX_WIDTH)
		value.y = clampi(value.y, MIN_HEIGHT, MAX_HEIGHT)

		if size != value:
			size = value

			_refresh()

@export
var initial_state: BoardStateData:
	set(value):
		if initial_state != value:
			initial_state = value

			_refresh()

@export_group("External Dependencies")

@export
var turn_tracker: TurnTracker

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

@onready
var placement_calculator: PlacementCalculator = %PlacementCalculator

signal score_changed(black_score: int, white_score: int)
signal no_plays_available(colour: BoardCell.CounterType)
signal board_reset

func _ready() -> void:
	if turn_tracker:
		turn_tracker.starting_colour_changed.connect(_handle_starting_colour_changed)
		turn_tracker.next_colour_changed.connect(_handle_next_colour_changed)

	if score_ui:
		score_ui.ready.connect(_handle_score_ui_ready)

	board_state.score_changed.connect(score_changed.emit)

	if not Engine.is_editor_hint():
		if turn_tracker:
			board_creator.turn_ended.connect(turn_tracker.next)

		if game_buttons:
			game_buttons.restarted.connect(_handle_restarted)

		if debug_handler:
			debug_handler.play_random.connect(_handle_play_random)

	_refresh()

func _refresh() -> void:
	if board_creator:
		board_creator.render_board(size, self)

		_connect_initial_state()

func _connect_initial_state() -> void:
	if initial_state and initial_state.changed.get_connections().size() <= 0:
		initial_state.changed.connect(
			func() -> void:
				board_creator.inject(initial_state)
		)

	board_creator.inject(initial_state)

func _handle_starting_colour_changed(colour: BoardCell.CounterType) -> void:
	_accept_next_colour(colour)

func _handle_next_colour_changed(colour: BoardCell.CounterType) -> void:
	_accept_next_colour(colour)

	var available_play_count := placement_calculator.get_plays()

	if available_play_count <= 0:
		no_plays_available.emit(colour)

func _accept_next_colour(colour: BoardCell.CounterType) -> void:
	if board_creator:
		board_creator.set_next_colour(colour)

	if cell_data_pool:
		cell_data_pool.next_colour = colour

func _handle_score_ui_ready() -> void:
	board_state.update_score()

func _handle_restarted() -> void:
	if board_state:
		board_state.reset_board()

	if board_creator:
		board_creator.inject(initial_state)

	placement_calculator.refresh()

	board_reset.emit()

func _handle_play_random() -> void:
	if board_creator:
		board_creator.play_random()
