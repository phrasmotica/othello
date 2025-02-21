class_name Board3DEntranceAnimation extends Node

@export
var board: Board3D

@export
var camera_rig: CameraRig

signal finished

func run() -> void:
	if board and camera_rig:
		_prepare_for_entrance()

		var tween := create_tween()

		tween.tween_property(
			board,
			"scale",
			Vector3.ONE,
			0.5
		).set_delay(0.5)

		tween.tween_callback(_after_entrance)
		tween.tween_callback(finished.emit)

func _prepare_for_entrance() -> void:
	camera_rig.top_level = true
	board.scale = 0.01 * Vector3.ONE

	var counters := get_tree().get_nodes_in_group("counters3d")
	for c in counters:
		(c as Counter3D).disable_rigid_body()

func _after_entrance() -> void:
	var counters := get_tree().get_nodes_in_group("counters3d")
	for c in counters:
		(c as Counter3D).enable_rigid_body()

	camera_rig.top_level = false
	board.scale = Vector3.ONE
