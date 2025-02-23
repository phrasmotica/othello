extends Node3D

@export
var entrance: EntranceOrchestrator

@export
var camera: Camera3D

@export
var board: Board3D

@export
var counter_box: CounterBox

const RAY_LENGTH := 100.0

var _board_is_busy := false
var _hovered_cell: BoardCell3D

func _ready() -> void:
	set_physics_process(false)

	if entrance:
		entrance.finished.connect(set_physics_process.bind(true))

	if board:
		board.busy_changed.connect(_handle_board_busy_changed)

func _handle_board_busy_changed(is_busy: bool) -> void:
	_board_is_busy = is_busy

	if is_busy:
		print("Board is now busy, pausing mouse processing")
	else:
		print("Board is no longer busy, resuming mouse processing")

func _physics_process(_delta: float) -> void:
	var cell := _get_hovered_cell()

	if _hovered_cell != cell:
		_hovered_cell = cell

	if cell:
		if board:
			if cell.cannot_place:
				MouseCursor.set_default()

				if not _board_is_busy:
					board.highlight_cell(-1)
					_hovered_cell = null
			else:
				if not _board_is_busy:
					MouseCursor.set_pointing()
					board.highlight_cell(cell.index)
	else:
		MouseCursor.set_default()

		if board and not _board_is_busy:
			board.highlight_cell(-1)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("Left button was clicked at ", event.position)

				if _hovered_cell and not _hovered_cell.cannot_place and board:
					MouseCursor.set_default()

					if counter_box:
						counter_box.take_top()

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
