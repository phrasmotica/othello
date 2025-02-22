@tool
class_name OthelloGameLogic3D extends OthelloGameLogic

@export
var board_3d: Board3D

func _ready() -> void:
	_connect_children()

func _connect_children() -> void:
	if board_3d:
		if turn_tracker:
			turn_tracker.connect_to_board_3d(board_3d)

			turn_tracker.next_colour_changed.connect(next_colour_changed.emit)
			turn_tracker.game_ended.connect(game_ended.emit)

		if score:
			score.connect_to_board_3d(board_3d)

			score.score_changed.connect(score_changed.emit)

		if placement_calculator:
			placement_calculator.connect_to_board_3d(board_3d)

		if ray_calculator:
			ray_calculator.connect_to_board_3d(board_3d)

func restart_game() -> void:
	Globals.init_finished = false

	if board_3d:
		board_3d.restart()

	Globals.init_finished = true

	if placement_calculator:
		placement_calculator.refresh()

	_emit_restarted()
