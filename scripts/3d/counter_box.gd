@tool
class_name CounterBox extends Node3D

@export
var disable_environment := false:
	set(value):
		disable_environment = value

		_refresh()

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
	if world_environment:
		_original_environment = world_environment.environment

	set_process(false)

	_refresh()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("peek_counter_box"):
		peek()

	if Input.is_action_just_released("peek_counter_box"):
		unpeek()

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
		animation_player.play("peek")

func unpeek() -> void:
	if animation_player and not animation_player.is_playing():
		animation_player.play_backwards("peek")

func _refresh() -> void:
	if world_environment:
		world_environment.environment = _get_environment()

	if light:
		light.visible = not disable_environment

	if camera:
		camera.visible = not disable_environment

func _get_environment() -> Environment:
	return null if disable_environment else _original_environment
