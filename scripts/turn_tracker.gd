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
var placement_calculator: PlacementCalculator

const SKIP_TYPES := [TurnType.BLACK_SKIP, TurnType.WHITE_SKIP, TurnType.BOTH_SKIP]

var _board: Board
var _board_3d: Board3D
var _next_turn_colour: BoardStateData.CounterType
var _next_turn_type: TurnType
var _has_game_ended := false
var _turn_skip_duration := 3.0

signal next_turn_started(turn_type: TurnType)
signal game_ended

func _ready() -> void:
	assert(placement_calculator)

	get_tree().root.ready.connect(_start_game)

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

func _start_game() -> void:
	_next_turn_colour = starting_colour

	if starting_colour == BoardStateData.CounterType.BLACK:
		_next_turn_type = TurnType.BLACK_PLAY

	if starting_colour == BoardStateData.CounterType.WHITE:
		_next_turn_type = TurnType.WHITE_PLAY

	# MEDIUM: it's possible for the starting colour to not have a play on the
	# initial board state. So we might need to skip the turn here instead
	_start_turn()

func _go_to_next_turn() -> void:
	var next_colour := _compute_next_colour(_next_turn_colour)
	var next_type := _compute_type(next_colour)

	if _has_game_ended:
		return

	_next_turn_colour = next_colour
	_next_turn_type = next_type

	print("Turn ended, next: %d" % next_colour)

	if SKIP_TYPES.has(_next_turn_type):
		_skip_turn()
	else:
		_start_turn()

func _compute_next_colour(colour: BoardStateData.CounterType) -> BoardStateData.CounterType:
	if colour == BoardStateData.CounterType.BLACK:
		return BoardStateData.CounterType.WHITE

	return BoardStateData.CounterType.BLACK

func _compute_type(colour: BoardStateData.CounterType) -> TurnType:
	var has_plays := _check_available_plays(colour)

	if colour == BoardStateData.CounterType.WHITE:
		return TurnType.WHITE_PLAY if has_plays else TurnType.WHITE_SKIP

	return TurnType.BLACK_PLAY if has_plays else TurnType.BLACK_SKIP

func _check_available_plays(colour: BoardStateData.CounterType) -> bool:
	var plays_dict := placement_calculator.compute_plays()

	var colours_that_can_play: Array[BoardStateData.CounterType] = []

	for key: BoardStateData.CounterType in plays_dict.keys():
		if plays_dict[key].can_play():
			colours_that_can_play.append(key)

	# HIGH: move this check out into its own function
	if colours_that_can_play.size() <= 0:
		print("Both colours cannot play!")

		if _board_3d.is_free():
			_end_game()
		else:
			SignalHelper.once(_board_3d.freed, _end_game)

		return true

	print("Colours that can play: ", colours_that_can_play)

	return colours_that_can_play.has(colour)

func _start_turn() -> void:
	print("Starting turn: %d" % _next_turn_type)

	_broadcast_colour(_next_turn_colour)

	next_turn_started.emit(_next_turn_type)

func _skip_turn() -> void:
	print("Skipping turn: %d" % _next_turn_type)

	_broadcast_colour(_next_turn_colour)

	next_turn_started.emit(_next_turn_type)

	# HIGH: instead of pausing and then resuming automatically here, provide a
	# way for scenes that depend on this one to acknowledge the skipped turn.
	# After that, progress to the next turn.
	SignalHelper.once_after(_turn_skip_duration, _go_to_next_turn)

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

	_start_game()

func _broadcast_colour(colour: BoardStateData.CounterType) -> void:
	if _board:
		_board.set_next_colour(colour)

	if _board_3d:
		_board_3d.set_next_colour(colour)

	placement_calculator.refresh_for(colour)
