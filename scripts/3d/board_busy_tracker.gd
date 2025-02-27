class_name BoardBusyTracker extends Node

@export
var cells_manager_3d: CellsManager3D

var _last_busy := false

var _busy_lifting: Array[int] = []
var _busy_flipping: Array[int] = []
var _busy_dropping: Array[int] = []

signal busy_changed(is_busy: bool)
signal freed

func accept_cells() -> void:
	if not cells_manager_3d:
		return

	var tracked_count := 0

	for idx in cells_manager_3d.count():
		var cell := cells_manager_3d.get_cell_3d(idx)

		cell.counter_placing.connect(_handle_counter_placing.bind(idx))

		cell.counter_confirmed.connect(
			func(data: BoardCellData) -> void:
				_handle_counter_confirmed(idx, data)
		)

		cell.counter_lift_started.connect(_handle_lift_started.bind(idx))
		cell.counter_lift_finished.connect(_handle_lift_finished.bind(idx))

		cell.counter_flip_started.connect(_handle_flip_started.bind(idx))
		cell.counter_flip_finished.connect(_handle_flip_finished.bind(idx))

		cell.counter_drop_started.connect(_handle_drop_started.bind(idx))
		cell.counter_drop_finished.connect(_handle_drop_finished.bind(idx))

		tracked_count += 1

	print("BoardBusyTracker accepted %d cell(s)" % tracked_count)

func _handle_counter_placing(idx: int) -> void:
	_handle_drop_started(idx)

func _handle_counter_confirmed(idx: int, _data: BoardCellData) -> void:
	_handle_drop_finished(idx)

func _handle_lift_started(idx: int) -> void:
	if not _busy_lifting.has(idx):
		_busy_lifting.append(idx)

		_broadcast()

func _handle_lift_finished(idx: int) -> void:
	if _busy_lifting.has(idx):
		_busy_lifting.erase(idx)

		_broadcast()

func _handle_flip_started(idx: int) -> void:
	if not _busy_flipping.has(idx):
		_busy_flipping.append(idx)

		_broadcast()

func _handle_flip_finished(idx: int) -> void:
	if _busy_flipping.has(idx):
		_busy_flipping.erase(idx)

		_broadcast()

func _handle_drop_started(idx: int) -> void:
	if not _busy_dropping.has(idx):
		_busy_dropping.append(idx)

		_broadcast()

func _handle_drop_finished(idx: int) -> void:
	if _busy_dropping.has(idx):
		_busy_dropping.erase(idx)

		_broadcast()

func is_free() -> bool:
	return _busy_lifting.is_empty() and _busy_flipping.is_empty() and _busy_dropping.is_empty()

func _broadcast() -> void:
	var is_busy := not is_free()

	if _last_busy != is_busy:
		busy_changed.emit(is_busy)

	if _last_busy and not is_busy:
		freed.emit()

	_last_busy = is_busy
