@tool
class_name CounterBox extends Node3D

@export
var board: Board3D

@onready
var counter_spawner: CounterSpawner = %CounterSpawner

@onready
var animation_player: AnimationPlayer = %AnimationPlayer

var _is_settled := false

signal spawning_finished

func _ready() -> void:
	if not Engine.is_editor_hint():
		if board:
			SignalHelper.persist(board.initial_state_ready, _update_spawner)
			SignalHelper.persist(board.board_reset, _handle_board_reset)

	set_process(false)

func _update_spawner(data: BoardStateData) -> void:
	if counter_spawner:
		var amount := data.get_remaining_cell_count()

		print("Setting spawn amount to %d" % amount)

		counter_spawner.spawn_amount = amount

func _handle_board_reset(old_state: BoardStateData, new_state: BoardStateData) -> void:
	var counters_removed := old_state.get_counter_count() - new_state.get_counter_count()
	counter_spawner.spawn_amount = counters_removed

	print("Respawning %d counter(s) that were placed on the board" % counters_removed)

	start_spawn(true)

func start_spawn(skip_finished := false) -> void:
	if counter_spawner:
		SignalHelper.once(
			counter_spawner.finished,
			_handle_spawning_finished.bind(skip_finished)
		)

		counter_spawner.spawn_counters()

func _handle_spawning_finished(skip_finished: bool) -> void:
	_is_settled = true
	set_process(true)

	if not skip_finished:
		spawning_finished.emit()

func peek() -> void:
	if animation_player and not animation_player.is_playing():
		SignalHelper.once(animation_player.animation_finished, _handle_animation_finished)

		animation_player.play("peek")

func unpeek() -> void:
	if animation_player and not animation_player.is_playing():
		animation_player.play_backwards("peek")

func _handle_animation_finished(anim_name: StringName) -> void:
	if anim_name == "peek":
		if not Input.is_action_pressed("peek_counter_box"):
			unpeek()

func take_top() -> void:
	if not _is_settled:
		return

	var counters := counter_spawner.get_counters()

	if counters.is_empty():
		return

	counters.sort_custom(
		func(c: Counter3D, d: Counter3D) -> bool:
			return c.position.y > d.position.y
	)

	var top_counter: Counter3D = counters.pop_front()
	top_counter.queue_free()
