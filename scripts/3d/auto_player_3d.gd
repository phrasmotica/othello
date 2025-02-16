extends Node

@export_range(2.0, 5.0)
var play_interval := 2.0

@export
var board: Board3D

func _ready() -> void:
	_start_autoplay()

func _start_autoplay() -> void:
	if not board:
		return

	var tween := create_tween().set_loops()

	tween.tween_callback(
		func() -> void:
			if board:
				board.play_random()
	).set_delay(play_interval)
