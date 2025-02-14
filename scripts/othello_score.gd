@tool
class_name OthelloScore extends Node

signal score_changed(black_score: int, white_score: int)

func connect_to_board(board: Board) -> void:
	board.state_changed.connect(_handle_state_changed)

func update_score(data: BoardStateData) -> void:
	var black_score := 0
	var white_score := 0

	for v: BoardCellData in data.cells_data.values():
		if v.is_white():
			white_score += 1
		elif v.is_black():
			black_score += 1

	score_changed.emit(black_score, white_score)

func _handle_state_changed(data: BoardStateData) -> void:
	update_score(data)
