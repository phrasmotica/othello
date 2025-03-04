@tool
class_name TurnTracker extends Node

@export
var starting_colour := BoardStateData.CounterType.BLACK:
	set(value):
		if starting_colour != value:
			starting_colour = value

			_emit()

@export
var placement_calculator: PlacementCalculator

var _board_3d: Board3D
var _next_turn_colour: BoardStateData.CounterType
var _has_game_ended := false

signal starting_colour_changed(colour: BoardStateData.CounterType)
signal next_colour_changed(colour: BoardStateData.CounterType)
signal game_ended

func _ready() -> void:
	get_tree().root.ready.connect(_emit)

	if placement_calculator:
		placement_calculator.computed_plays_available.connect(_handle_computed_plays_available)

func connect_to_board(board: Board) -> void:
	board.cell_changed.connect(_handle_cell_changed)
	board.board_reset.connect(_handle_board_reset)

	starting_colour_changed.connect(board.set_next_colour)
	next_colour_changed.connect(board.set_next_colour)

func connect_to_board_3d(board_3d: Board3D) -> void:
	_board_3d = board_3d

	board_3d.cell_changed.connect(_handle_cell_changed)
	board_3d.board_reset.connect(_handle_board_reset)

	starting_colour_changed.connect(board_3d.set_next_colour)
	next_colour_changed.connect(board_3d.set_next_colour)

func _emit() -> void:
	starting_colour_changed.emit(starting_colour)

func _go_to_next_turn(turn_skipped := false) -> void:
	if _has_game_ended:
		return

	_next_turn_colour = ((_next_turn_colour + 1) % 2) as BoardStateData.CounterType

	if turn_skipped:
		print("Turn skipped! %d plays next" % _next_turn_colour)
	else:
		print("Turn ended, %d plays next" % _next_turn_colour)

	next_colour_changed.emit(_next_turn_colour)

func _handle_computed_plays_available(plays: Dictionary) -> void:
	var colours_that_can_play: Array[BoardStateData.CounterType] = []

	for key: BoardStateData.CounterType in plays.keys():
		if plays[key].size() > 0:
			colours_that_can_play.append(key)

	if colours_that_can_play.size() <= 0:
		print("Both colours cannot play!")

		if _board_3d.is_free():
			_end_game()
		else:
			SignalHelper.once(_board_3d.freed, _end_game)

		return

	print("Colours that can play: ", colours_that_can_play)

	if not colours_that_can_play.has(_next_turn_colour):
		# this is quite an edge case... it might be impossible for colour A to
		# play, then colour B cannot play, then colour A can play again. But
		# we have this here for completeness
		print("%d cannot play!" % _next_turn_colour)
		_go_to_next_turn(true)

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

	_next_turn_colour = starting_colour

	next_colour_changed.emit(_next_turn_colour)
