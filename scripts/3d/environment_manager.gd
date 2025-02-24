@tool
class_name EnvironmentManager extends Node

@export
var selected_index := -1:
	set(value):
		var new_index := clampi(value, 0, 1)

		selected_index = new_index

		handle_index_changed(selected_index)

@export
var purple_room: Node3D

@export
var world_environment: WorldEnvironment

@onready
var space_galaxy_environment: Environment = load("res://resources/environment_space_galaxy.tres")

# HIGH: make all of this more generalisable. Create a resource class for a given
# environment setting, containing an environment resource, lists of nodes to
# show/hide, etc.

func handle_index_changed(index: int) -> void:
	if not purple_room or not world_environment:
		return

	if index == 0:
		purple_room.show()
		world_environment.environment = null

	if index == 1:
		purple_room.hide()
		world_environment.environment = space_galaxy_environment
