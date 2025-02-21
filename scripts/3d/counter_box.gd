@tool
extends Node3D

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

var _original_environment: Environment

func _ready() -> void:
	if world_environment:
		_original_environment = world_environment.environment

	_refresh()

	if Engine.is_editor_hint():
		return

	if counter_spawner:
		counter_spawner.spawn_counters()

func _refresh() -> void:
	if world_environment:
		world_environment.environment = _get_environment()

	if light:
		light.visible = not disable_environment

	if camera:
		camera.visible = not disable_environment

func _get_environment() -> Environment:
	return null if disable_environment else _original_environment
