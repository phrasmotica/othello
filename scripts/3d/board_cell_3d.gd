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
var debug_mode := false:
	set(value):
		if debug_mode != value:
			debug_mode = value

			_refresh()

@export
var even_tile_mesh: BoxMesh

@export
var odd_tile_mesh: BoxMesh

@onready
var tile_mesh_instance: MeshInstance3D = %TileMesh

@onready
var index_label: Label3D = %IndexLabel3D

@onready
var counter: Counter3D = %Counter

var _col := 0
var _row := 0

signal cell_pressed
signal counter_changed(data: BoardCellData)

func _ready():
	if not Engine.is_editor_hint():
		Globals.toggled_debug_mode.connect(_handle_toggled_debug_mode)

	_refresh()

func _handle_toggled_debug_mode(is_debug: bool) -> void:
	debug_mode = is_debug

func set_pos(col: int, row: int) -> void:
	_col = col
	_row = row

	_refresh()

func _refresh() -> void:
	# if debug_mode and cannot_place:
	# 	modulate = Color.DIM_GRAY
	# else:
	# 	modulate = Color.WHITE

	if tile_mesh_instance:
		var is_odd := (_col + _row) % 2 == 0
		tile_mesh_instance.mesh = odd_tile_mesh if is_odd else even_tile_mesh

	if counter:
		counter.visible = cell_data.has_counter() if cell_data else false
		counter.is_white = cell_data.is_white() if cell_data else false

	# if counter_preview:
	# 	if cell_data and cell_data.has_counter():
	# 		counter_preview.visible = false

	# 	counter_preview.is_white = next_colour == BoardStateData.CounterType.WHITE

	# if mouse_area_button:
	# 	if cannot_place:
	# 		mouse_area_button.disabled = true
	# 		mouse_area_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
	# 	else:
	# 		mouse_area_button.disabled = false
	# 		mouse_area_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	if index_label:
		index_label.visible = debug_mode
		index_label.text = str(index)

func place_counter(data: BoardCellData) -> void:
	cell_data = data
	counter_changed.emit(cell_data)
