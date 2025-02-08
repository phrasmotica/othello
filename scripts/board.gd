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

@onready
var board_creator: BoardCreator = %BoardCreator

@onready
var board_state: BoardState = %BoardState

signal score_changed(black_score: int, white_score: int)

func _ready() -> void:
	if not Engine.is_editor_hint():
		board_state.score_changed.connect(score_changed.emit)

	_refresh()

func _refresh() -> void:
	board_creator.render_board(size, self)
