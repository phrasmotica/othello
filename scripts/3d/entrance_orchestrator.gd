class_name EntranceOrchestrator extends Node

@export
var board_entrance_animation: Board3DEntranceAnimation

@export
var camera_rig_to_box_animation: CameraRigToBoxAnimation

@export
var counter_box: CounterBox

@export
var game_ui: GameUI

signal finished

func _ready() -> void:
	assert(board_entrance_animation != null)
	assert(camera_rig_to_box_animation != null)
	assert(counter_box != null)
	assert(game_ui != null)

	_queue(board_entrance_animation.finished, camera_rig_to_box_animation.anim_in, 0.5)
	_queue(camera_rig_to_box_animation.finished_in, counter_box.start_spawn)
	_queue(counter_box.spawning_finished, camera_rig_to_box_animation.anim_out)
	_queue(camera_rig_to_box_animation.finished_out, game_ui.anim_in, 0.5)

	SignalHelper.chain(game_ui.starting_animation_finished, finished)

func _queue(sig: Signal, callable: Callable, delay := 0.0) -> void:
	if delay > 0:
		SignalHelper.persist(
			sig,
			func() -> void:
				await get_tree().create_timer(delay).timeout

				callable.call()
		)
	else:
		SignalHelper.persist(sig, callable)

func run() -> void:
	game_ui.hide()

	board_entrance_animation.run()
