@tool
class_name Counter3D extends RigidBody3D

@export
var is_white: bool:
	set(value):
		is_white = value

		flip_if_needed()

@export
var debug_name := ""

@export
var prevent_tweening := false

@export
var black_counter_mesh: CylinderMesh

@export
var white_counter_mesh: CylinderMesh

@onready
var counter_halves: Node3D = %CounterHalves

var _rotated_to_white := false

signal landed_on_board

func _ready() -> void:
	body_entered.connect(_handle_body_entered)

	_setup_rigidbody()

	_refresh()

func _setup_rigidbody() -> void:
	contact_monitor = true
	max_contacts_reported = 10

func _refresh() -> void:
	if counter_halves:
		counter_halves.rotation_degrees.x = 180 if is_white else 0
		_rotated_to_white = is_white

func flip_if_needed() -> void:
	if Engine.is_editor_hint() or not Globals.init_finished or prevent_tweening:
		_refresh()
	else:
		_rotate_tween()

func _rotate_tween() -> void:
	if not counter_halves:
		return

	if _rotated_to_white == is_white:
		return

	gravity_scale = 0
	contact_monitor = false

	var final_rotation := int(counter_halves.rotation_degrees.x + 180) % 360

	var tween := create_tween()

	tween.tween_property(
		self,
		"position:y",
		position.y + 0.5,
		0.5
	)

	tween.tween_property(
		counter_halves,
		"rotation_degrees:x",
		final_rotation,
		0.5
	)

	tween.finished.connect(
		func() -> void:
			counter_halves.rotation_degrees.x = final_rotation
			_rotated_to_white = is_white

			print("Finished rotating %s to %.1f" % [debug_name, final_rotation])

			gravity_scale = 1
			contact_monitor = true
	)

func _handle_body_entered(_body: Node) -> void:
	landed_on_board.emit()
