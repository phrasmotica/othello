@tool
class_name Counter3D extends Node3D

@export
var debug_name := ""

@export
var is_white: bool:
	set(value):
		is_white = value

		flip_if_needed()

@export_group("Animation")

@export
var prevent_tweening := false

@export
var flip_delay := 0.0

@export_range(0.1, 0.5)
var lift_duration := 0.5

@onready
var rigid_body: RigidBody3D = %RigidBody3D

@onready
var counter_halves: CounterHalves = %CounterHalves

var _rotated_to_white := false
var _is_flipping := false

signal landed_on_board

func _ready() -> void:
	rigid_body.body_entered.connect(_handle_body_entered)

	enable_rigid_body()

	_refresh()

func disable_rigid_body() -> void:
	if rigid_body:
		rigid_body.freeze = true

func enable_rigid_body() -> void:
	rigid_body.contact_monitor = true
	rigid_body.max_contacts_reported = 10
	rigid_body.freeze = false

func _refresh() -> void:
	if counter_halves:
		counter_halves.is_white = is_white

	_rotated_to_white = is_white

func flip_if_needed() -> void:
	if Engine.is_editor_hint() or not Globals.init_finished or prevent_tweening:
		_refresh()
	else:
		_rotate_tween()

func update_gravity(cell_data: BoardCellData) -> void:
	# don't make the counter suddenly fall back to the board if it's in the
	# middle of the flipping animation
	if not _is_flipping:
		rigid_body.gravity_scale = 1 if cell_data and cell_data.has_counter() else 0

func _rotate_tween() -> void:
	if _rotated_to_white == is_white:
		return

	if not counter_halves:
		return

	counter_halves.set_meta("debug_name", "%sCounterHalves" % debug_name)

	_is_flipping = true

	rigid_body.gravity_scale = 0
	rigid_body.contact_monitor = false

	var tween := create_tween()

	tween.tween_property(
		self,
		"position:y",
		position.y + 0.5,
		lift_duration
	).set_delay(flip_delay)

	counter_halves.rotate_tween(tween)

	tween.finished.connect(
		func() -> void:
			_rotated_to_white = is_white
			_is_flipping = false

			rigid_body.gravity_scale = 1
			rigid_body.contact_monitor = true
	)

func _handle_body_entered(_body: Node) -> void:
	landed_on_board.emit()
