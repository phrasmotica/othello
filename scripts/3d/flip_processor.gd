class_name FlipProcessor extends Node

@export
var board_state: BoardState

@export
var cell_data_pool: CellDataPool

@export
var cells_manager: CellsManager3D

var _flips_finished_count := 0

signal flips_finished(indexes: Array[int])

func perform_flips(indexes: Array[int], flip_delay_factor: float) -> void:
	if indexes.size() < 0:
		return

	var count := 0

	_flips_finished_count = 0

	for i in indexes:
		var cell := cells_manager.get_cell_3d(i)

		cell.flip_delay = flip_delay_factor * count

		SignalHelper.persist(
			cell.counter_flip_finished,
			_handle_counter_flip_finished.bind(i, cell.cell_data, indexes)
		)

		cell.cell_data = cell_data_pool.flip(cell.cell_data)

		count += 1

func _handle_counter_flip_finished(idx: int, cell_data: BoardCellData, indexes: Array[int]) -> void:
	board_state.set_cell(idx, cell_data, false)

	_flips_finished_count += 1

	if _flips_finished_count >= indexes.size():
		flips_finished.emit(indexes)
