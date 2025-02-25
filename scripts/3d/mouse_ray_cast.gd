extends Node3D

@export
var entrance: EntranceOrchestrator

@export
var camera: Camera3D

@export
var board: Board3D

@export
var settings_menu_rig: SettingsMenuRig

@export
var counter_box: CounterBox

const RAY_LENGTH := 100.0

var _board_is_busy := false
var _hovered_cell: BoardCell3D
var _is_ready := false

func _ready() -> void:
	_set_enabled(false)

	if entrance:
		SignalHelper.persist(entrance.finished, _handle_entrance_finished)

	if board:
		SignalHelper.persist(board.busy_changed, _handle_board_busy_changed)

	if settings_menu_rig:
		SignalHelper.persist(
			settings_menu_rig.settings_menu_toggled,
			_handle_settings_menu_visibility_changed
		)

func _handle_entrance_finished() -> void:
	_is_ready = true
	_set_enabled(true)

func _handle_board_busy_changed(is_busy: bool) -> void:
	_board_is_busy = is_busy

	if is_busy:
		print("Board is now busy, pausing mouse processing")
	else:
		print("Board is no longer busy, resuming mouse processing")

func _handle_settings_menu_visibility_changed(menu_is_visible: bool) -> void:
	var is_enabled := _is_ready and not menu_is_visible
	_set_enabled(is_enabled)

func _set_enabled(is_enabled: bool) -> void:
	print("MouseRayCast processing %s" % is_enabled)

	set_physics_process(is_enabled)

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
	var result := _cast_ray(2) # board tiles only, not counters

	if result.has("collider"):
		var tile := result["collider"] as StaticBody3D
		var cell := tile.get_parent_node_3d() as BoardCell3D
		return cell

	return null

func _cast_ray(collision_mask: int) -> Dictionary:
	if not camera:
		return {}

	# https://forum.godotengine.org/t/godot-4-how-to-cast-a-ray-from-mouse-position-towards-camera-orientation-in-3d/5280/2
	var mouse_pos := get_viewport().get_mouse_position()

	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH

	var space_state = get_world_3d().direct_space_state

	var params := PhysicsRayQueryParameters3D.new()
	params.from = from
	params.to = to
	params.collision_mask = collision_mask

	return space_state.intersect_ray(params)
