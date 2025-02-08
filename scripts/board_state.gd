class_name BoardState extends Node

@export
var board_creator: BoardCreator

var _counters := {}

signal score_changed(black_score: int, white_score: int)

func _ready() -> void:
	if board_creator:
		board_creator.cell_counter_changed.connect(_handle_cell_counter_changed)

func _update_score() -> void:
	var black_score := 0
	var white_score := 0

	for v in _counters.values():
		if v == BoardCell.CounterPresence.WHITE:
			white_score += 1
		elif v == BoardCell.CounterPresence.BLACK:
			black_score += 1

	score_changed.emit(black_score, white_score)

func _handle_cell_counter_changed(index: int, type: BoardCell.CounterPresence) -> void:
	_counters[index] = type

	_update_score()
