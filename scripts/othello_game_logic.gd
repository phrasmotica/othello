@tool
class_name OthelloGameLogic extends Node

@export
var board: Board:
	set(value):
		board = value

		_connect_children()

@onready
var turn_tracker: TurnTracker = %TurnTracker

@onready
var score: OthelloScore = %ScoreTracker

@onready
var placement_calculator: PlacementCalculator = %PlacementCalculator

@onready
var ray_calculator: RayCalculator = %RayCalculator

signal score_changed(black_score: int, white_score: int, result: OthelloScore.GameResult)
signal next_turn_started(turn_type: TurnTracker.TurnType)
signal game_ended
signal game_restarted

func _ready() -> void:
	_connect_children()

func _connect_children() -> void:
	if board:
		if turn_tracker:
			turn_tracker.connect_to_board(board)

			turn_tracker.next_turn_started.connect(next_turn_started.emit)
			turn_tracker.game_ended.connect(game_ended.emit)

		if score:
			score.connect_to_board(board)

			score.score_changed.connect(score_changed.emit)

		if placement_calculator:
			placement_calculator.connect_to_board(board)

		if ray_calculator:
			ray_calculator.connect_to_board(board)

func continue_turn() -> void:
	if turn_tracker:
		turn_tracker.continue_turn()

func restart_game() -> void:
	if board:
		board.restart()

	_emit_restarted()

func _emit_restarted():
	game_restarted.emit()
