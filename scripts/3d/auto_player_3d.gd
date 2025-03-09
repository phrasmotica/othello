class_name AutoPlayer3D extends Node

@export_range(1.0, 5.0)
var play_interval := 1.0

@export
var game_logic: OthelloGameLogic3D

@export
var board: Board3D

func _ready() -> void:
	if game_logic:
		SignalHelper.persist(
			game_logic.next_turn_started,
			_wait_and_play
		)

func _wait_and_play(type: TurnTracker.TurnType) -> void:
	if TurnTracker.SKIP_TYPES.has(type):
		SignalHelper.once_after(play_interval, game_logic.continue_turn)
	else:
		SignalHelper.once_after(play_interval, _play_random)

func _play_random() -> void:
	if board:
		board.play_random()
