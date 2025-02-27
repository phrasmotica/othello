@tool
class_name Counter3D extends Node3D

@export
var debug_name := ""

@export
var is_white: bool:
	set(value):
		is_white = value

		flip_if_needed()

@export
var debug_mode := false:
	set(value):
		if debug_mode != value:
			debug_mode = value

			_refresh()

@export_group("Animation")

@export
var prevent_tweening := false

@export
var flip_delay := 0.0

@onready
var rigid_body: RigidBody3D = %RigidBody3D

@onready
var counter_halves: CounterHalves = %CounterHalves

@onready
var rigid_body_indicator: FlagIndicator = %RigidBodyIndicator

signal refreshed
signal needs_flip(counter_halves: CounterHalves, flip_delay: float)
signal landed_on_board

func _ready() -> void:
	rigid_body.body_entered.connect(_handle_body_entered)

	enable_rigid_body()

	_refresh()

func disable_rigid_body() -> void:
	if rigid_body:
		rigid_body.freeze = true
		rigid_body_indicator.is_active = false

func enable_rigid_body() -> void:
	if rigid_body:
		rigid_body.freeze = false
		rigid_body_indicator.is_active = true

func reset_position() -> void:
	if rigid_body:
		disable_rigid_body()

		rigid_body.position = Vector3.ZERO

		enable_rigid_body()

func _refresh() -> void:
	if counter_halves:
		counter_halves.is_white = is_white

	if rigid_body_indicator:
		rigid_body_indicator.visible = debug_mode

	refreshed.emit()

func flip_if_needed() -> void:
	if Engine.is_editor_hint() or not Globals.init_finished or prevent_tweening:
		_refresh()
	else:
		needs_flip.emit(counter_halves, flip_delay)

func update_gravity(g_scale: int) -> void:
	rigid_body.gravity_scale = g_scale

func _handle_body_entered(_body: Node) -> void:
	landed_on_board.emit()
