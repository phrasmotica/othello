## Script for forwarding input events to a 3D SubViewport node.
## Adapted from https://github.com/godotengine/godot-demo-projects/blob/4.2-31d1c0c/viewport/gui_in_3d/gui_3d.gd
class_name GUI3D extends Node3D

# Used for checking if the mouse is inside the Area3D.
var _is_mouse_inside := false

# The last processed input touch/mouse event. To calculate relative movement.
var _last_event_pos_2d: Vector2

# The time of the last event in seconds since engine start.
var _last_event_time: float = -1.0

@export
var viewport: SubViewport

@export
var quad: MeshInstance3D

@export
var area: Area3D

func _ready() -> void:
	area.mouse_entered.connect(_mouse_entered_area)
	area.mouse_exited.connect(_mouse_exited_area)
	area.input_event.connect(_mouse_input_event)

func _mouse_entered_area() -> void:
	_is_mouse_inside = true

func _mouse_exited_area() -> void:
	_is_mouse_inside = false

func _unhandled_input(event) -> void:
	# Check if the event is a non-mouse/non-touch event
	for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
		if is_instance_of(event, mouse_event):
			# If the event is a mouse/touch event, then we can ignore it here, because it will be
			# handled via Physics Picking.
			return

	viewport.push_input(event)

func _mouse_input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	var event_pos_3d := _compute_event_pos_3d(event_position)
	var event_pos_2d := _compute_event_pos_2d(event_pos_3d)

	# Current time in seconds since engine start.
	var now: float = Time.get_ticks_msec() / 1000.0

	_process_input_event(event, event_pos_2d, now)

	_last_event_pos_2d = event_pos_2d
	_last_event_time = now

	# send the processed input event to the viewport
	viewport.push_input(event)

## Converts the event position in world coordinate space into a coordinate
## space relative to the Area3D node.
func _compute_event_pos_3d(event_position: Vector3) -> Vector3:
	var event_pos_3d := event_position

	# NOTE: affine_inverse accounts for the Area3D node's scale, rotation, and position in the scene!
	event_pos_3d = quad.global_transform.affine_inverse() * event_pos_3d

	return event_pos_3d

## Converts the relative event position from 3D to 2D.
## We need to do these conversions so the event's position is in the viewport's coordinate system.
func _compute_event_pos_2d(event_pos_3d: Vector3) -> Vector2:
	# Get mesh size to detect edges and make conversions. This code only support PlaneMesh and QuadMesh.
	var quad_mesh_size = quad.mesh.size

	var event_pos_2d := Vector2(event_pos_3d.x, -event_pos_3d.y)

	if _is_mouse_inside:
		# Right now the event position is in the range [(-quad_size/2), (quad_size/2)]
		# We need to convert it into the range [-0.5, 0.5]
		event_pos_2d.x = event_pos_2d.x / quad_mesh_size.x
		event_pos_2d.y = event_pos_2d.y / quad_mesh_size.y

		# Now normalise it
		event_pos_2d.x += 0.5
		event_pos_2d.y += 0.5

		# Finally, we convert the position to the range [0, viewport.size]
		event_pos_2d.x *= viewport.size.x
		event_pos_2d.y *= viewport.size.y

	elif _last_event_pos_2d != null:
		# Fall back to the last known event position.
		event_pos_2d = _last_event_pos_2d

	return event_pos_2d

func _process_input_event(event: InputEvent, event_pos_2d: Vector2, now: float) -> void:
	# Set the event's position and global position.
	event.position = event_pos_2d

	if event is InputEventMouse:
		event.global_position = event_pos_2d

	# Calculate the relative event distance.
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		# If there is not a stored previous position, then we'll assume there is no relative motion.
		if _last_event_pos_2d == null:
			event.relative = Vector2.ZERO

		# If there is a stored previous position, then we'll calculate the relative position by subtracting
		# the previous position from the new position. This will give us the distance the event traveled from prev_pos.
		else:
			event.relative = event_pos_2d - _last_event_pos_2d
			event.velocity = event.relative / (now - _last_event_time)
