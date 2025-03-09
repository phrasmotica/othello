@tool
class_name OthelloGameLogic3D extends OthelloGameLogic

@export
var entrance: EntranceOrchestrator

@export
var board_3d: Board3D

@onready
var state_tracker: BoardStateTracker = %BoardStateTracker

@onready
var cell_toggler: CellToggler = %CellToggler

func _ready() -> void:
	assert(turn_tracker)

	_connect_children()

func _connect_children() -> void:
	if not Engine.is_editor_hint():
		var ready_sig := board_3d.ready

		# broadcast the board state for the first time, etc
		SignalHelper.once(ready_sig, turn_tracker.before_start_game)

		if entrance:
			# start the game only once everything is settled
			SignalHelper.once(entrance.finished, turn_tracker.start_game)
		else:
			SignalHelper.once(ready_sig, turn_tracker.start_game)

	if board_3d:
		if state_tracker:
			state_tracker.connect_to_board_3d(board_3d)

		turn_tracker.connect_to_board_3d(board_3d)

		SignalHelper.chain(turn_tracker.next_turn_started, next_turn_started)
		SignalHelper.chain(turn_tracker.game_ended, game_ended)

		if score:
			score.connect_to_board_3d(board_3d)

			SignalHelper.chain(score.score_changed, score_changed)

		if cell_toggler:
			cell_toggler.connect_to_board_3d(board_3d)

		if ray_calculator:
			ray_calculator.connect_to_board_3d(board_3d)

func restart_game() -> void:
	if not board_3d:
		return

	print("Restarting the game.")

	Globals.init_finished = false

	if board_3d:
		board_3d.restart()

	Globals.init_finished = true

	_emit_restarted()
