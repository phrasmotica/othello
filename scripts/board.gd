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
var starting_colour := BoardCell.CounterType.BLACK:
	set(value):
		if starting_colour != value:
			starting_colour = value

			if board_creator:
				board_creator.set_next_colour(starting_colour)

@onready
var board_creator: BoardCreator = %BoardCreator

@onready
var board_state: BoardState = %BoardState

var _next_turn_colour := starting_colour

signal score_changed(black_score: int, white_score: int)

func _ready() -> void:
	if not Engine.is_editor_hint():
		board_state.score_changed.connect(score_changed.emit)
		board_creator.turn_ended.connect(_handle_turn_ended)

	_refresh()

func _refresh() -> void:
	if board_creator:
		board_creator.render_board(size, self)

func _handle_turn_ended() -> void:
	_next_turn_colour = ((_next_turn_colour + 1) % 2) as BoardCell.CounterType

	print("Turn ended, now it's %d turn" % _next_turn_colour)

	board_creator.set_next_colour(_next_turn_colour)
