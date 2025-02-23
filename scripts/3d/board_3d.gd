@tool
class_name Board3D extends Node3D

@export
var initial_state: BoardStateData:
	set(value):
		if initial_state != value:
			initial_state = value

			_initialise()

@export_group("Animation")

@export_range(0.1, 0.5)
var flip_delay_factor := 0.1

@export
var show_flip_previews := true

@onready
var board_creator: BoardCreator3D = %BoardCreator3D

@onready
var board_state: BoardState = %BoardState

@onready
var cells_manager_3d: CellsManager3D = %CellsManager3D

@onready
var busy_tracker: BoardBusyTracker = %BoardBusyTracker

@onready
var cell_data_pool: CellDataPool = %CellDataPool

@onready
var flip_processor: FlipProcessor = %FlipProcessor

signal initial_state_ready(data: BoardStateData)

signal busy_changed(is_busy: bool)
signal freed(is_busy: bool)

signal cell_highlighted(index: int)

# TODO: this acts as a "turn_ended" signal, but we should only emit it
# once all the counters involved have landed back on the board...
signal cell_changed(index: int, data: BoardCellData)

signal state_changed(data: BoardStateData)
signal flips_finished(indexes: Array[int])
signal board_reset

func _ready() -> void:
	if not Engine.is_editor_hint():
		SignalHelper.chain(board_state.cell_changed, cell_changed)
		SignalHelper.chain(board_state.state_changed, state_changed)

		SignalHelper.chain(flip_processor.flips_finished, flips_finished)

	_initialise()

	if not Engine.is_editor_hint():
		SignalHelper.once_next_frame(initial_state_ready.emit.bind(initial_state))

		Globals.init_finished = true
		print("Init finished")

func _initialise() -> void:
	_inject_state()

	if Engine.is_editor_hint():
		_connect_initial_state()

func _inject_state() -> void:
	if board_creator:
		board_creator.inject(initial_state, self)

	if not Engine.is_editor_hint():
		if busy_tracker:
			busy_tracker.accept_cells()

			SignalHelper.chain(busy_tracker.busy_changed, busy_changed)
			SignalHelper.chain(busy_tracker.freed, freed)

func _connect_initial_state() -> void:
	if initial_state and initial_state.changed.get_connections().size() <= 0:
		initial_state.changed.connect(_inject_state)

func set_next_colour(colour: BoardStateData.CounterType) -> void:
	if cells_manager_3d:
		cells_manager_3d.set_next_colour(colour)

	if board_state:
		board_state.set_next_colour(colour)

	if cell_data_pool:
		cell_data_pool.next_colour = colour

func restart() -> void:
	if board_state:
		board_state.restart_game()

	if board_creator:
		board_creator.inject(initial_state, self)

	board_reset.emit()

func play_at(cell: BoardCell3D) -> void:
	if cell:
		print("Placing counter in cell %d" % cell.index)

		cell.show_preview = false
		cell.place_counter(cell_data_pool.get_next())

func play_random() -> void:
	var cell := cells_manager_3d.get_random_placeable_cell_3d()

	if cell:
		print("Placing counter randomly in cell %d" % cell.index)

		cell.place_counter(cell_data_pool.get_next())

func perform_flips(indexes: Array[int]) -> void:
	flip_processor.perform_flips(indexes, flip_delay_factor)

func preview_flips(indexes: Array[int]) -> void:
	for i in cells_manager_3d.count():
		var cell := cells_manager_3d.get_cell_3d(i)

		if show_flip_previews and indexes.has(i):
			cell.preview_flip()
		else:
			cell.unpreview_flip()

func enable_cell(idx: int, enabled: bool) -> void:
	var cell := cells_manager_3d.get_cell_3d(idx)
	cell.cannot_place = not enabled

func highlight_cell(idx: int) -> void:
	for i in cells_manager_3d.count():
		var cell := cells_manager_3d.get_cell_3d(i)
		cell.show_preview = cell.index == idx

	cell_highlighted.emit(idx)
