@tool
class_name FlagIndicator extends MeshInstance3D

@export
var is_active := false:
	set(value):
		is_active = value

		_refresh()

@onready
var active_mesh: SphereMesh = load("res://meshes/flag_indicator_active_mesh.tres")

@onready
var inactive_mesh: SphereMesh = load("res://meshes/flag_indicator_inactive_mesh.tres")

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	mesh = active_mesh if is_active else inactive_mesh
