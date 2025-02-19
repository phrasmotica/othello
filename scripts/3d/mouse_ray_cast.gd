extends Node3D

@export
var entrance_animation: Board3DEntranceAnimation

@export
var camera: Camera3D

@export
var board: Board3D

const RAY_LENGTH := 100.0

var _hovered_cell: BoardCell3D

func _ready() -> void:
	set_physics_process(false)

	if entrance_animation:
		entrance_animation.finished.connect(set_physics_process.bind(true))

func _physics_process(_delta: float) -> void:
	# HIGH: don't do this if the board is currently doing an animation
	var cell := _get_hovered_cell()

	if cell:
		if _hovered_cell != cell:
			_hovered_cell = cell

			if board:
				if cell.cannot_place:
					board.highlight_cell(-1)
					_hovered_cell = null
				else:
					board.highlight_cell(cell.index)
	elif board:
		board.highlight_cell(-1)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("Left button was clicked at ", event.position)

				if _hovered_cell and not _hovered_cell.cannot_place and board:
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
