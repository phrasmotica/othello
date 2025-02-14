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

var _next_turn_colour: BoardStateData.CounterType

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

func _emit() -> void:
	starting_colour_changed.emit(starting_colour)

func _go_to_next_turn() -> void:
	_next_turn_colour = ((_next_turn_colour + 1) % 2) as BoardStateData.CounterType

	print("Turn ended, %d plays next" % _next_turn_colour)

	next_colour_changed.emit(_next_turn_colour)

func _handle_computed_plays_available(plays: Dictionary) -> void:
	var colours_that_can_play: Array[BoardStateData.CounterType] = []

	for key: BoardStateData.CounterType in plays.keys():
		if plays[key].size() > 0:
			colours_that_can_play.append(key)

	if colours_that_can_play.size() <= 0:
		print("Both colours cannot play!")

		# ensure the game is only ended after all of the next_colour_changed
		# connections have finished, since this method is directly called from
		# one of them...
		get_tree().process_frame.connect(_end_game, CONNECT_ONE_SHOT)
		return

	if not colours_that_can_play.has(_next_turn_colour):
		# this is quite an edge case... it might be impossible for colour A to
		# play, then colour B cannot play, then colour A can play again. But
		# we have this here for completeness
		print("%d cannot play!" % _next_turn_colour)
		_go_to_next_turn()

func _end_game() -> void:
	print("Game ended!")
	game_ended.emit()

func _handle_cell_changed(_index: int, _data: BoardCellData) -> void:
	_go_to_next_turn()

func _handle_board_reset() -> void:
	_next_turn_colour = starting_colour

	next_colour_changed.emit(_next_turn_colour)
