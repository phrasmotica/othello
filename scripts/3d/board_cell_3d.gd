@tool
class_name BoardCell3D extends Node3D

@export
var cell_data: BoardCellData:
	set(value):
		cell_data = value

		_refresh()

@export
var next_colour := BoardStateData.CounterType.BLACK:
	set(value):
		if next_colour != value:
			next_colour = value

			_refresh()

@export
var index: int = 0:
	set(value):
		if index != value:
			index = value

			_refresh()

@export
var cannot_place := false:
	set(value):
		if cannot_place != value:
			cannot_place = value

			_refresh()

@export
var show_preview := false:
	set(value):
		if show_preview != value:
			show_preview = value

			_refresh()

@export
var debug_mode := false:
	set(value):
		if debug_mode != value:
			debug_mode = value

			_refresh()

@export
var even_tile_mesh: BoxMesh

@export
var odd_tile_mesh: BoxMesh

@export
var disabled_tile_mesh: BoxMesh

@export_group("Animation")

@export
var flip_delay := 0.0

@onready
var tile_mesh_instance: MeshInstance3D = %TileMesh

@onready
var index_label: Label3D = %IndexLabel3D

@onready
var counter_lifter: CounterLifter = %CounterLifter

@onready
var counter_flipper: CounterFlipper = %CounterFlipper

@onready
var counter: Counter3D = %Counter

@onready
var counter_preview: CounterPreview3D = %CounterPreview

var _col := 0
var _row := 0

signal counter_placing
signal counter_confirmed(data: BoardCellData)
signal counter_lift_started
signal counter_lift_finished
signal counter_flip_started
signal counter_flip_finished
signal counter_drop_started
signal counter_drop_finished

func _ready():
	if not Engine.is_editor_hint():
		SignalHelper.persist(Globals.toggled_debug_mode, _handle_toggled_debug_mode)

		SignalHelper.chain(counter_lifter.lift_started, counter_lift_started)
		SignalHelper.chain(counter_lifter.lift_finished, counter_lift_finished)

		SignalHelper.chain(counter_flipper.flip_started, counter_flip_started)
		SignalHelper.persist(counter_flipper.flip_finished, _handle_flip_finished)

		SignalHelper.chain(counter_lifter.drop_started, counter_drop_started)
		SignalHelper.chain(counter_lifter.drop_finished, counter_drop_finished)

	_refresh()

func _handle_flip_finished() -> void:
	if counter_lifter:
		counter_lifter.drop()

	counter_flip_finished.emit()

func _handle_toggled_debug_mode(is_debug: bool) -> void:
	debug_mode = is_debug

func set_pos(col: int, row: int) -> void:
	_col = col
	_row = row

	_refresh()

func _refresh() -> void:
	_refresh_tile_mesh()

	var has_counter := cell_data and cell_data.has_counter()

	if counter:
		counter.debug_name = "Counter%d" % index
		counter.debug_mode = debug_mode
		counter.visible = has_counter

		counter.flip_delay = flip_delay
		counter.is_white = cell_data.is_white() if cell_data else false
		counter.update_gravity(1 if has_counter else 0)

	if counter_preview:
		counter_preview.visible = (show_preview) and not has_counter

		counter_preview.is_white = next_colour == BoardStateData.CounterType.WHITE

	if index_label:
		index_label.visible = debug_mode
		index_label.text = str(index)

func _refresh_tile_mesh() -> void:
	if tile_mesh_instance:
		if debug_mode and cannot_place:
			tile_mesh_instance.mesh = disabled_tile_mesh
		else:
			var is_odd := (_col + _row) % 2 == 0
			tile_mesh_instance.mesh = odd_tile_mesh if is_odd else even_tile_mesh

func preview_flip() -> void:
	if counter_lifter:
		counter_lifter.lift()

func unpreview_flip() -> void:
	if counter_lifter:
		counter_lifter.drop()

func place_counter(data: BoardCellData) -> void:
	if not counter:
		return

	counter_placing.emit()

	counter.prevent_tweening = true
	counter.reset_position()

	cell_data = data

	counter.prevent_tweening = false

	var callable := _handle_counter_landed_on_board.bind(cell_data)
	SignalHelper.once(counter.landed_on_board, callable)

func _handle_counter_landed_on_board(data: BoardCellData) -> void:
	counter.stick_to_board()

	counter_confirmed.emit(data)

func restart() -> void:
	if counter:
		counter.reset_position()

	if counter_lifter:
		counter_lifter.stop_animations()

	if counter_flipper:
		counter_flipper.stop_animations()
