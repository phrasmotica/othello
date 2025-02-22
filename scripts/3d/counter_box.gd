@tool
class_name CounterBox extends Node3D

@export
var disable_environment := false:
	set(value):
		disable_environment = value

		_refresh()

@export
var board: Board3D

@onready
var world_environment: WorldEnvironment = %WorldEnvironment

@onready
var light: DirectionalLight3D = %DirectionalLight3D

@onready
var camera: Camera3D = %Camera3D

@onready
var counter_spawner: CounterSpawner = %CounterSpawner

@onready
var animation_player: AnimationPlayer = %AnimationPlayer

var _original_environment: Environment
var _is_settled := false

signal spawning_finished

func _ready() -> void:
	if board:
		SignalHelper.persist(board.initial_state_ready, _update_spawner)

	if world_environment:
		_original_environment = world_environment.environment

	set_process(false)

	_refresh()

func _update_spawner(data: BoardStateData) -> void:
	if counter_spawner:
		counter_spawner.spawn_amount = data.get_remaining_cell_count()

func start_spawn() -> void:
	if counter_spawner:
		SignalHelper.once(counter_spawner.finished, _handle_spawning_finished)

		counter_spawner.spawn_counters()

func _handle_spawning_finished() -> void:
	_is_settled = true
	set_process(true)

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

func _refresh() -> void:
	if world_environment:
		world_environment.environment = _get_environment()

	if light:
		light.visible = not disable_environment

	if camera:
		camera.visible = not disable_environment

func _get_environment() -> Environment:
	return null if disable_environment else _original_environment
