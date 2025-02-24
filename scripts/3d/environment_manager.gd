@tool
class_name EnvironmentManager extends Node

@export
var selected_index := -1:
	set(value):
		selected_index = clampi(value, 0, 1)

		_refresh()

@export
var world_environment: WorldEnvironment

@export
var options: Array[EnvironmentOption] = []

func _refresh() -> void:
	if not world_environment:
		return

	if selected_index < 0 or selected_index >= options.size():
		return

	var option := options[selected_index]

	world_environment.environment = option.environment

	for p in option.nodes_to_show:
		(get_node(p) as Node3D).show()

	for p in option.nodes_to_hide:
		(get_node(p) as Node3D).hide()
