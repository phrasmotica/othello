@tool
class_name TurnTracker extends Node

@export
var starting_colour := BoardCell.CounterType.BLACK:
	set(value):
		if starting_colour != value:
			starting_colour = value

			_emit()

@export_group("External Dependencies")

@export
var board: Board

var _next_turn_colour: BoardCell.CounterType
var _last_turn_passed := false

signal starting_colour_changed(colour: BoardCell.CounterType)
signal next_colour_changed(colour: BoardCell.CounterType)
signal game_ended

func _ready() -> void:
	get_tree().root.ready.connect(_emit)

	if board:
		board.no_plays_available.connect(_handle_no_plays_available)
		board.board_reset.connect(_handle_board_reset)

func _emit() -> void:
	starting_colour_changed.emit(starting_colour)

func next() -> void:
	_go_to_next_turn()

func _go_to_next_turn() -> void:
	_next_turn_colour = ((_next_turn_colour + 1) % 2) as BoardCell.CounterType

	print("Turn ended, now it's %d turn" % _next_turn_colour)

	# HIGH: don't emit this if the game has ended. This is being emitted twice
	# after the game has already ended, for some reason...
	next_colour_changed.emit(_next_turn_colour)

func _handle_no_plays_available(_colour: BoardCell.CounterType) -> void:
	if _last_turn_passed:
		print("Game ended!")
		game_ended.emit()
		return

	# MEDIUM: if there are no possible plays, force the current player to click a
	# "continue" button
	print("Skipping turn")
	_last_turn_passed = true
	_go_to_next_turn()

func _handle_board_reset() -> void:
	_next_turn_colour = starting_colour
	next_colour_changed.emit(_next_turn_colour)

	_last_turn_passed = false
