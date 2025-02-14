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

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	if counter_halves:
		counter_halves.rotation_degrees.x = 180 if is_white else 0
