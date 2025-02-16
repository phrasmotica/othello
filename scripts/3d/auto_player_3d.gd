class_name AutoPlayer3D extends Node

@export_range(2.0, 5.0)
var play_interval := 2.0

@export
var board: Board3D

var _tween: Tween

func _ready() -> void:
	_start_autoplay()

func _start_autoplay() -> void:
	if not board:
		return

	_tween = create_tween().set_loops()

	_tween.tween_callback(
		func() -> void:
			if board:
				board.play_random()
	).set_delay(play_interval)

func stop_autoplay() -> void:
	if _tween:
		_tween.stop()
