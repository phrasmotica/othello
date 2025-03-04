class_name FlipProcessor extends Node

@export
var board_state: BoardState

@export
var cell_data_pool: CellDataPool

@export
var cells_manager: CellsManager3D

var _flips_finished_count := 0
var _new_state_callbacks: Array[Callable] = []

signal flips_finished(indexes: Array[int])

func perform_flips(indexes: Array[int], flip_delay_factor: float) -> void:
	if indexes.size() < 0:
		return

	var count := 0

	_flips_finished_count = 0
	_new_state_callbacks.clear()

	for i in indexes:
		var cell := cells_manager.get_cell_3d(i)

		cell.flip_delay = flip_delay_factor * count

		# the callable needs to be a lambda rather than a bound callable,
		# because bound callables capture the value of outer variables rather
		# than getting them by reference. So cell.cell_data would still have its
		# old value if we used _handle_counter_drop_finished.bind(...)
		SignalHelper.once(
			cell.counter_drop_finished,
			func() -> void:
				_handle_counter_drop_finished(i, cell.cell_data, indexes)
		)

		cell.cell_data = cell_data_pool.flip(cell.cell_data)

		count += 1

func _handle_counter_drop_finished(idx: int, cell_data: BoardCellData, indexes: Array[int]) -> void:
	_new_state_callbacks.append(board_state.set_cell.bind(idx, cell_data, false))

	_flips_finished_count += 1

	if _flips_finished_count >= indexes.size():
		_process_new_board_state()

		flips_finished.emit(indexes)

func _process_new_board_state() -> void:
	if _new_state_callbacks.size() <= 0:
		print("No board state callbacks to process")
		return

	for c in _new_state_callbacks:
		c.call()

	print("Processed %d new board state callback(s)" % _new_state_callbacks.size())

	_new_state_callbacks.clear()
