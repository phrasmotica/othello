@tool
class_name TurnTracker extends Node

enum TurnType { BLACK_PLAY, WHITE_PLAY, BLACK_SKIP, WHITE_SKIP, BOTH_SKIP }

@export
var starting_colour := BoardStateData.CounterType.BLACK:
	set(value):
		if starting_colour != value:
			starting_colour = value

			_broadcast_colour(value)

@export
var cell_toggler: CellToggler

@export
var play_calculator: PlayCalculator

@export
var ray_calculator: RayCalculator

const SKIP_TYPES := [TurnType.BLACK_SKIP, TurnType.WHITE_SKIP, TurnType.BOTH_SKIP]

var _board: Board
var _board_3d: Board3D
var _next_turn_colour: BoardStateData.CounterType
var _next_turn_type: TurnType
var _has_game_ended := false

signal next_turn_started(turn_type: TurnType)
signal game_ended

func _ready() -> void:
	assert(cell_toggler)
	assert(play_calculator)

func connect_to_board(board: Board) -> void:
	_board = board

	board.cell_changed.connect(_handle_cell_changed)
	board.board_reset.connect(_handle_board_reset)

func connect_to_board_3d(board_3d: Board3D) -> void:
	_board_3d = board_3d

	board_3d.board_reset.connect(_handle_board_reset)
	board_3d.flips_finished.connect(_handle_flips_finished)

func _handle_flips_finished(_indexes: Array[int]) -> void:
	_go_to_next_turn()

func before_start_game() -> void:
	_next_turn_colour = starting_colour

	_broadcast_colour(_next_turn_colour)

func start_game() -> void:
	_process_turn()

func continue_turn() -> void:
	_go_to_next_turn()

func _go_to_next_turn() -> void:
	if play_calculator.both_cannot_play():
		print("Both colours cannot play!")

		if _board_3d.is_free():
			_end_game()
		else:
			SignalHelper.once(_board_3d.freed, _end_game)

		return

	_next_turn_colour = _compute_next_colour(_next_turn_colour)

	print("Turn ended, next: %d" % _next_turn_colour)

	_process_turn()

func _process_turn() -> void:
	_next_turn_type = _compute_type(_next_turn_colour)

	if SKIP_TYPES.has(_next_turn_type):
		_skip_turn()
	else:
		_start_turn()

func _compute_next_colour(colour: BoardStateData.CounterType) -> BoardStateData.CounterType:
	if colour == BoardStateData.CounterType.BLACK:
		return BoardStateData.CounterType.WHITE

	return BoardStateData.CounterType.BLACK

func _compute_type(colour: BoardStateData.CounterType) -> TurnType:
	var has_plays := play_calculator.can_play(colour)
	if not has_plays:
		print("%d cannot play" % colour)

	if colour == BoardStateData.CounterType.WHITE:
		return TurnType.WHITE_PLAY if has_plays else TurnType.WHITE_SKIP

	return TurnType.BLACK_PLAY if has_plays else TurnType.BLACK_SKIP

func _start_turn() -> void:
	print("Starting turn: %d" % _next_turn_type)

	_broadcast_colour(_next_turn_colour)

	next_turn_started.emit(_next_turn_type)

func _skip_turn() -> void:
	print("Skipping turn: %d" % _next_turn_type)

	_broadcast_colour(_next_turn_colour)

	next_turn_started.emit(_next_turn_type)

func _end_game() -> void:
	print("Game ended!")

	_has_game_ended = true

	game_ended.emit()

func _handle_cell_changed(_index: int, _data: BoardCellData) -> void:
	if _board_3d:
		SignalHelper.once(_board_3d.freed, _go_to_next_turn)
	else:
		_go_to_next_turn()

func _handle_board_reset(_old_state: BoardStateData, _new_state: BoardStateData) -> void:
	_has_game_ended = false

	start_game()

func _broadcast_colour(colour: BoardStateData.CounterType) -> void:
	if _board:
		_board.set_next_colour(colour)

	if _board_3d:
		_board_3d.set_next_colour(colour)

	if ray_calculator:
		ray_calculator.set_colour(colour)

	if cell_toggler:
		cell_toggler.refresh_for(colour)
