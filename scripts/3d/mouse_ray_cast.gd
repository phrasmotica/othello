extends Node3D

@export
var camera: Camera3D

@export
var board: Board3D

const RAY_LENGTH = 1000.0

var _hovered_cell: BoardCell3D

func _physics_process(_delta: float) -> void:
	var cell := _get_hovered_cell()

	if cell:
		if _hovered_cell != cell:
			_hovered_cell = cell

			print("Now hovering over cell %d" % cell.index)

			if board:
				if cell.cannot_place:
					board.highlight_cell(-1)
				else:
					board.highlight_cell(cell.index)
	elif board:
		board.highlight_cell(-1)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("Left button was clicked at ", event.position)

				if _hovered_cell and board:
					board.play_at(_hovered_cell)

func _get_hovered_cell() -> BoardCell3D:
	if not camera:
		return

	# https://forum.godotengine.org/t/godot-4-how-to-cast-a-ray-from-mouse-position-towards-camera-orientation-in-3d/5280/2
	var mouse_pos := get_viewport().get_mouse_position()

	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH

	var space_state = get_world_3d().direct_space_state

	var params := PhysicsRayQueryParameters3D.new()
	params.from = from
	params.to = to
	params.collision_mask = 2 # board tiles only, not counters

	var result := space_state.intersect_ray(params)

	if result.has("collider"):
		var tile := result["collider"] as StaticBody3D
		var cell := tile.get_parent_node_3d() as BoardCell3D
		return cell

	return null
