@tool
class_name Counter3D extends RigidBody3D

@export
var debug_name := ""

@export
var is_white: bool:
	set(value):
		is_white = value

		flip_if_needed()

@export
var prevent_tweening := false

@onready
var counter_halves: CounterHalves = %CounterHalves

var _rotated_to_white := false
var _is_flipping := false

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
		counter_halves.is_white = is_white

	_rotated_to_white = is_white

func flip_if_needed() -> void:
	if Engine.is_editor_hint() or not Globals.init_finished or prevent_tweening:
		_refresh()
	else:
		_rotate_tween()

func update_gravity(cell_data: BoardCellData) -> void:
	# don't make the counter suddenly fall back to the board if it's in the
	# middle of the flipping animation
	if not _is_flipping:
		gravity_scale = 1 if cell_data and cell_data.has_counter() else 0

func _rotate_tween() -> void:
	if _rotated_to_white == is_white:
		return

	if not counter_halves:
		return

	counter_halves.set_meta("debug_name", "%sCounterHalves" % debug_name)

	gravity_scale = 0
	_is_flipping = true
	contact_monitor = false

	var tween := create_tween()

	tween.tween_property(
		self,
		"position:y",
		position.y + 0.5,
		0.5
	)

	counter_halves.rotate_tween(tween)

	tween.finished.connect(
		func() -> void:
			_rotated_to_white = is_white
			gravity_scale = 1
			_is_flipping = false
			contact_monitor = true
	)

func _handle_body_entered(_body: Node) -> void:
	landed_on_board.emit()
