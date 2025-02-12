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

	next_colour_changed.emit(_next_turn_colour)

func _handle_no_plays_available(colour: BoardCell.CounterType) -> void:
	print("No plays available for %d" % colour)

	if _last_turn_passed:
		print("Game ended!")

		# MEDIUM: currently this method is called when a signal is emitted as
		# part of the connections to next_colour_changed, which means that other
		# connections to next_colour_changed are called after the game has
		# ended. One such connection is to update the score UI with a
		# description of whose turn it currently is. We are working around this
		# by delaying the game_ended emission until the next frame, but it'd be
		# more ideal for this game-ended check to happen entirely outside of the
		# next-colour-changed signal connections...

		# ensure the game is only ended after all of the next_colour_changed
		# connections have finished, since this method is directly called from
		# one of them...
		get_tree().process_frame.connect(game_ended.emit, CONNECT_ONE_SHOT)
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
