class_name AutoPlayer3D extends Node

@export_range(2.0, 5.0)
var play_interval := 2.0

@export
var game_logic: OthelloGameLogic3D

@export
var board: Board3D

var _tween: Tween

func _ready() -> void:
	if game_logic:
		SignalHelper.persist(game_logic.game_ended, stop_autoplay)

	_start_autoplay()

func _start_autoplay() -> void:
	if not board:
		return

	print("Starting autoplay")

	_tween = create_tween().set_loops()

	_tween.tween_callback(
		func() -> void:
			if board:
				board.play_random()
	).set_delay(play_interval)

func stop_autoplay() -> void:
	print("Stopping autoplay")

	if _tween:
		_tween.stop()
