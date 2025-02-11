@tool
class_name BoardState extends Node

@export
var board_creator: BoardCreator

var _counters := {}

signal score_changed(black_score: int, white_score: int)

func _ready() -> void:
	if board_creator:
		board_creator.cell_counter_changed.connect(_handle_cell_counter_changed)
		board_creator.board_reset.connect(_handle_board_reset)

func update_score() -> void:
	var black_score := 0
	var white_score := 0

	for v: BoardCellData in _counters.values():
		if v.is_white():
			white_score += 1
		elif v.is_black():
			black_score += 1

	score_changed.emit(black_score, white_score)

func _handle_cell_counter_changed(index: int, data: BoardCellData) -> void:
	_counters[index] = data

	update_score()

func _handle_board_reset() -> void:
	_counters.clear()

	update_score()
