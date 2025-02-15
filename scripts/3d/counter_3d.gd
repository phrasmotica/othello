@tool
class_name Counter3D extends RigidBody3D

@export
var is_white: bool:
	set(value):
		is_white = value

		_refresh()

@export
var black_counter_mesh: CylinderMesh

@export
var white_counter_mesh: CylinderMesh

@onready
var counter_halves: Node3D = %CounterHalves

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

func _handle_body_entered(_body: Node) -> void:
	landed_on_board.emit()
