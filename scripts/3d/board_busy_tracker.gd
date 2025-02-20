class_name BoardBusyTracker extends Node

@export
var cells_manager_3d: CellsManager3D

var _busy_indexes: Array[int] = []

signal busy_changed(is_busy: bool)

func accept_cells() -> void:
	if not cells_manager_3d:
		return

	var tracked_count := 0

	for idx in cells_manager_3d.count():
		var cell := cells_manager_3d.get_cell_3d(idx)

		cell.counter_flip_started.connect(_handle_flip_started.bind(idx))
		cell.counter_flip_finished.connect(_handle_flip_finished.bind(idx))

		tracked_count += 1

	print("BoardBusyTracker accepted %d cell(s)" % tracked_count)

func _handle_flip_started(idx: int) -> void:
	if not _busy_indexes.has(idx):
		_busy_indexes.append(idx)

		_broadcast()

func _handle_flip_finished(idx: int) -> void:
	if _busy_indexes.has(idx):
		_busy_indexes.erase(idx)

		_broadcast()

func _broadcast() -> void:
	busy_changed.emit(_busy_indexes.size() > 0)
